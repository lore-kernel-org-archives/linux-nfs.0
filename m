Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:33533 "EHLO
	mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1424396AbcFHTla (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Jun 2016 15:41:30 -0400
Received: by mail-oi0-f67.google.com with SMTP id x204so3576226oia.0
        for <linux-nfs@vger.kernel.org>; Wed, 08 Jun 2016 12:41:29 -0700 (PDT)
Subject: Re: [PATCH] Fix NFS option parsing bit-rot.
To: Trond Myklebust <trondmy@primarydata.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
References: <57560021.5030708@landley.net>
 <B4B27507-DD34-49D0-9BE9-01C9DA1A86FA@primarydata.com>
From: Rob Landley <rob@landley.net>
Message-ID: <575874E5.3070809@landley.net>
Date: Wed, 8 Jun 2016 14:41:25 -0500
MIME-Version: 1.0
In-Reply-To: <B4B27507-DD34-49D0-9BE9-01C9DA1A86FA@primarydata.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/06/2016 06:49 PM, Trond Myklebust wrote:
> On 6/6/16, 18:58, "Rob Landley" <rob@landley.net> wrote:
> 
>>From: Rob Landley <rob@landley.net>
>>
>>The kernel has string parsing code for NFS mount options, but it seems
>>to have bit-rotted over the years, so toybox mount needs the following
>>patch to be able to mount nfs. Without it, the kernel returns "invalid
>>argument" before sending any network traffic.
>>
>>For more information, see
>>http://lists.landley.net/pipermail/toybox-landley.net/2016-March/004790.html
...
> That will scribble over the parsed address.

You mean if you supply both -o addr=host and host:/ path name?
Because you can't leave off host:/ or it errors. If you do:

  mount("/tmp","/mnt","nfs",1,
    "port=9999,mountport=9999,nolock,v3,udp,addr=10.0.2.2");

It barfs because nfs_parse_devname() does:

  end = strchr(dev_name, ':');
  if (end == NULL)
    goto out_bad_devname;
...
out_bad_devname:
  dfprintk(MOUNT, "NFS: device name not in host:path format\n");
  return -EINVAL;

So addr= is at _best_ redundant. You MUST supply host:/ always,
the current code just wasn't using it. My patch makes it use it.

There's no other way to get the address set for the text
parsing path, when we enter nfs_validate_text_mount_data()
(the function I patched), mount_info.parsed will always be
zero.

But sure, he's a gratuitous for loop checking that you haven't
redundantly supplied both -o addr=host and host://path

Signed-off-by: Rob Landley <rob@landley.net>

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 2137e02..9b62d8b 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2130,11 +2130,28 @@ static int nfs_validate_text_mount_data(void *options,
 	int port = 0;
 	int max_namelen = PAGE_SIZE;
 	int max_pathlen = NFS_MAXPATHLEN;
+	int rc;
+	int i;
+	char *c;
 	struct sockaddr *sap = (struct sockaddr *)&args->nfs_server.address;
 
 	if (nfs_parse_mount_options((char *)options, args) == 0)
 		return -EINVAL;
 
+	rc = nfs_parse_devname(dev_name,
+				   &args->nfs_server.hostname,
+				   max_namelen,
+				   &args->nfs_server.export_path,
+				   max_pathlen);
+
+	for (i = 0, c = (void *)sap; i<sizeof(*sap); i++)
+		if (c[i]) break;
+	if (i == sizeof(*sap))
+		args->nfs_server.addrlen = rpc_pton(args->net,
+				args->nfs_server.hostname,
+				strlen(args->nfs_server.hostname),
+				sap, sizeof(args->nfs_server.address));
+
 	if (!nfs_verify_server_address(sap))
 		goto out_no_address;
 
@@ -2155,11 +2172,7 @@ static int nfs_validate_text_mount_data(void *options,
 
 	nfs_set_port(sap, &args->nfs_server.port, port);
 
-	return nfs_parse_devname(dev_name,
-				   &args->nfs_server.hostname,
-				   max_namelen,
-				   &args->nfs_server.export_path,
-				   max_pathlen);
+	return rc;
 
 #if !IS_ENABLED(CONFIG_NFS_V4)
 out_v4_not_compiled:
