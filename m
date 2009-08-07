From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [Patch 7/10] NFS Mount Configuration File (Vers 3)
Date: Fri, 07 Aug 2009 14:37:22 -0400
Message-ID: <4A7C7462.1090605@RedHat.com>
References: <4A7B2324.9090406@RedHat.com> <4A7B2515.2040304@RedHat.com>
	<E3DFEA95-A38E-446C-B9AB-3BA7E9837E94@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <E3DFEA95-A38E-446C-B9AB-3BA7E9837E94@oracle.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/06/2009 04:35 PM, Chuck Lever wrote:
> 
> On Aug 6, 2009, at 2:46 PM, Steve Dickson wrote:
>> commit eab66bd02db90965d1cbf4e100a274a4e3e6e29e
>> Author: Steve Dickson <steved@redhat.com>
>> Date:   Sun Aug 2 12:37:19 2009 -0400
>>
>>    Added hooks to the mount command that allow
>>    mount options to be set in a configuration file
>>
>>    Signed-off-by: Steve Dickson <steved@redhat.com>
>>
>> diff --git a/utils/mount/mount.c b/utils/mount/mount.c
>> index a668cd9..30d087e 100644
>> --- a/utils/mount/mount.c
>> +++ b/utils/mount/mount.c
>> @@ -47,6 +47,11 @@
>> #include "stropts.h"
>> #include "version.h"
>>
>> +#ifdef MOUNT_CONFIG
>> +#include "conffile.h"
>> +extern char *conf_get_mntopts(char *, char *, char *);
> 
> Can this forward declaration be added to conffile.h ?
> 
>> +#endif
>> +
>> char *progname;
>> int nfs_mount_data_version;
>> int nomtab;
>> @@ -474,6 +479,13 @@ int main(int argc, char *argv[])
>>     spec = argv[1];
>>     mount_point = argv[2];
>>
>> +#ifdef MOUNT_CONFIG
>> +    /*
>> +     * Read the the default mount options
>> +     */
>> +    conf_init();
>> +#endif
> 
> It would be cleaner if the #ifdefs were moved to conf_init() (and above,
> for the #include, and below, into conf_get_mntopts()).  If MOUNT_CONFIG
> isn't set, then configfile.o would just contain stubs, but it would then
> always be built.
> 
> Otherwise, we end up with each new feature adding #ifdefs in the
> mainline code, and eventually it becomes unreadable.
> 
I agree... there is the update to this patch:

commit 5225a4e8fbedc5c4f888691855dd3fe2e3eff9ad
Author: Steve Dickson <steved@redhat.com>
Date:   Fri Aug 7 14:29:07 2009 -0400

    Added hooks to the mount command that allow
    mount options to be set in a configuration file
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/utils/mount/Makefile.am b/utils/mount/Makefile.am
index a1b56ca..db7778f 100644
--- a/utils/mount/Makefile.am
+++ b/utils/mount/Makefile.am
@@ -15,7 +15,8 @@ mount_nfs_SOURCES = mount.c error.c network.c fstab.c token.c \
 		    nfsumount.c \
 		    mount_constants.h error.h network.h fstab.h token.h \
 		    parse_opt.h parse_dev.h \
-		    nfs4_mount.h nfs_mount4.h stropts.h version.h
+		    nfs4_mount.h nfs_mount4.h stropts.h version.h \
+			mount_config.h
 
 if MOUNT_CONFIG
 mount_nfs_SOURCES += configfile.c
diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index a668cd9..909fedf 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -37,6 +37,7 @@
 #include "xcommon.h"
 #include "nls.h"
 #include "mount_constants.h"
+#include "mount_config.h"
 #include "nfs_paths.h"
 #include "nfs_mntent.h"
 
@@ -474,6 +475,8 @@ int main(int argc, char *argv[])
 	spec = argv[1];
 	mount_point = argv[2];
 
+	mount_config_init();
+
 	argv[2] = argv[0]; /* so that getopt error messages are correct */
 	while ((c = getopt_long(argc - 2, argv + 2, "rvVwfno:hs",
 				longopts, NULL)) != -1) {
@@ -559,6 +562,10 @@ int main(int argc, char *argv[])
 		mnt_err = EX_USAGE;
 		goto out;
 	}
+	/*
+	 * Concatenate mount options from the configuration file
+	 */
+	mount_opts = mount_config_opts(spec, mount_point, mount_opts);
 
 	parse_opts(mount_opts, &flags, &extra_opts);
 
diff --git a/utils/mount/mount_config.h b/utils/mount/mount_config.h
new file mode 100644
index 0000000..2af9f9d
--- /dev/null
+++ b/utils/mount/mount_config.h
@@ -0,0 +1,47 @@
+#ifndef _LINUX_MOUNT__CONFIG_H
+#define _LINUX_MOUNT_CONFIG__H
+/*
+ * mount_config.h -- mount configuration file routines 
+ * Copyright (C) 2008 Red Hat, Inc <nfs@redhat.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2, or (at your option)
+ * any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ */
+
+inline void mount_config_init(void);
+
+#ifdef MOUNT_CONFIG
+#include "conffile.h"
+extern char *conf_get_mntopts(char *, char *, char *);
+
+inline void mount_config_init()
+{
+	/*
+	 * Read the the default mount options
+	 */
+	conf_init();
+}
+inline char *mount_config_opts(char *spec, 
+		char *mount_point, char *mount_opts)
+{
+	return conf_get_mntopts(spec, mount_point, mount_opts);
+}
+#else /* MOUNT_CONFIG */
+
+inline void mount_config_init() { }
+
+inline char *mount_config_opts(char *spec, 
+		char *mount_point, char *mount_opts)
+{
+	return mount_opts;
+}
+#endif /* MOUNT_CONFIG */
+#endif
