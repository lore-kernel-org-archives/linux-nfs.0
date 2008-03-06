From: Timo Aaltonen <tjaalton@cc.hut.fi>
Subject: Re: Last call for nfs-utils patches
Date: Fri, 7 Mar 2008 00:06:20 +0200 (EET)
Message-ID: <alpine.OSF.0.99.0803070004300.100983@replicant.hut.fi>
References: <47CD680B.1070106@RedHat.com>
	<alpine.OSF.0.99.0803060931390.100983@replicant.hut.fi>
	<47CFFE6D.3050507@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <47CFFE6D.3050507@RedHat.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 6 Mar 2008, Steve Dickson wrote:

> Timo Aaltonen wrote:
>> What about the changes which make rpc.gssd spam the syslog less, ie.
>> lowering the priority of two printerr's? It did the trick wonderfully,
>> no more syslog overflows when user creds have expired.
> Which patches are you referring to? It appears I missed them...

I didn't actually post anything yet, it was discussed recently though. But 
here it goes:

diff -Naur nfs-utils-1.1.1/utils/gssd/gss_util.c nfs-utils-1.1.1-new/utils/gssd/gss_util.c
--- nfs-utils-1.1.1/utils/gssd/gss_util.c       2007-10-19 06:07:28.000000000 +0300
+++ nfs-utils-1.1.1-new/utils/gssd/gss_util.c   2008-02-27 17:23:40.000000000 +0200
@@ -168,7 +168,7 @@
                 min = min_gss_buf.value;
         }

-       printerr(0, "ERROR: GSS-API: error in %s(): %s - %s\n",
+       printerr(1, "ERROR: GSS-API: error in %s(): %s - %s\n",
                  m, maj, min);

         if (maj_gss_buf.length != 0)
diff -Naur nfs-utils-1.1.1/utils/gssd/gssd_proc.c nfs-utils-1.1.1-new/utils/gssd/gssd_proc.c
--- nfs-utils-1.1.1/utils/gssd/gssd_proc.c      2007-10-19 06:07:28.000000000 +0300
+++ nfs-utils-1.1.1-new/utils/gssd/gssd_proc.c  2008-02-27 17:23:10.000000000 +0200
@@ -464,7 +464,7 @@
         if (write(k5_fd, buf, p - buf) < p - buf) goto out_err;
         return 0;
  out_err:
-       printerr(0, "Failed to write error downcall!\n");
+       printerr(1, "Failed to write error downcall!\n");
         return -1;
  }
