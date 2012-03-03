Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:10282 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751243Ab2CCRjK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 3 Mar 2012 12:39:10 -0500
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q23HdAw8011650
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Sat, 3 Mar 2012 12:39:10 -0500
Received: from badhat.bos.devel.redhat.com (vpn-9-158.rdu.redhat.com [10.11.9.158])
	by int-mx12.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id q23Hd97K008876
	for <linux-nfs@vger.kernel.org>; Sat, 3 Mar 2012 12:39:10 -0500
Message-ID: <4F525741.2060404@RedHat.com>
Date: Sat, 03 Mar 2012 12:39:13 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Get normalized paths for comparing NFS export paths
References: <1328233332-26020-1-git-send-email-malahal@us.ibm.com> <4F2BC1C0.8070900@panasas.com> <20120203231623.442fefde@notabene.brown> <20120203142945.GA31805@us.ibm.com> <4F2E620F.5090100@panasas.com> <20120207204401.GA31752@us.ibm.com> <4F511B21.1020907@RedHat.com> <20120302192758.GA28389@us.ibm.com> <4F513429.1050209@RedHat.com> <20120302220108.GA17119@us.ibm.com>
In-Reply-To: <20120302220108.GA17119@us.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/02/2012 05:01 PM, Malahal Naineni wrote:
> Steve Dickson [SteveD@redhat.com] wrote:
>> So what my patch does is "normalizes" the device name early
>> on in main, so the correct name used used through the mount
>> and when its written the mtab. Plus, for better or worses, 
>> since the new device name will always be shorter, I just 
>> reuse/rewrite the memory allocated for the argv vector.. 
>> Meaning there is no allocation... 
> 
> My problem is a bit different.
> 
> "mount -t nfs4 server:export /mnt" works but umount fails.
> 
> Notice that there is no '/' in the path!
> 
> Normalizing or just stripping leading '/'s early won't help with the
> above problem and since there is already a hack to strip the
> __trailing__ '/' that kernel adds to /proc/mounts file, I just made the
> existing hack it a bit better by normalizing.
>
How about something like this... It takes on both case early on...

Author: Steve Dickson <steved@redhat.com>
Date:   Sat Mar 3 12:31:23 2012 -0500

    mount.nfs: Validate device name syntax
    
    To ensure the device name is found at unmount time strip
    off the multiple '/' or add a '/' if one does not exist.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index eea00af..7b9ba8b 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -344,6 +344,52 @@ static void parse_opts(const char *options, int *flags, char **extra_opts)
 	}
 }
 
+/*
+ * To ensure the device is found at unmount time strip
+ * off the multiple '/' or add a '/' if one does not exist.
+ */
+static char *
+chk_devicename(char *spec) {
+
+	char *colen, *slash;
+
+	if (strstr(spec, "//") != NULL) {
+		if ((colen = strchr(spec, ':')) == NULL)
+			return NULL;
+
+		slash = (colen + 1);
+		while (*slash && *(slash+1) == '/')
+			slash++;
+		while (*slash)
+			*(++colen) = *(slash++);
+		*(colen+1) = '\0';
+
+		return spec;
+	} 
+
+	if (strchr(spec, '/') == NULL) {
+		char *colen, *ptr, *str, *dev;
+		
+		if ((colen = strchr(spec, ':')) == NULL)
+			return NULL;
+
+		dev = str = malloc(strlen(spec) + 2);
+		if (dev == NULL) 
+			return NULL;
+
+		ptr = spec;
+		while (ptr <= colen)
+			*(str++) = *(ptr++);
+		*str++='/';
+		while (*ptr)
+			*(str++) = *(ptr++);
+		*str='\0';
+		spec = dev;
+	}
+
+	return spec;
+}
+
 static int try_mount(char *spec, char *mount_point, int flags,
 			char *fs_type, char **extra_opts, char *mount_opts,
 			int fake, int bg)
@@ -445,6 +491,15 @@ int main(int argc, char *argv[])
 		}
 	}
 
+	/*
+	 * Validate the device name syntax
+	 */
+	if ((spec = chk_devicename(argv[1])) == NULL) {
+		nfs_error(_("%s: %s - Invalid device name syntax"),
+			progname, argv[1]);
+		goto out_usage;
+	}
+
 	if (strcmp(progname, "mount.nfs4") == 0)
 		fs_type = "nfs4";
 
