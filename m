From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [PATCH] - Adjust man pages for mountd/statd to match
 configuration options.
Date: Tue, 30 Oct 2007 08:18:51 -0400
Message-ID: <EXNANE017zynrvDOv5y00000832@exnane01.hq.netapp.com>
References: <18214.35373.27736.378763@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Steve Dickson <SteveD@redhat.com>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Imq3T-0003lc-28
	for nfs@lists.sourceforge.net; Tue, 30 Oct 2007 05:18:50 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Imq3Y-0006lS-CJ
	for nfs@lists.sourceforge.net; Tue, 30 Oct 2007 05:18:52 -0700
In-Reply-To: <18214.35373.27736.378763@notabene.brown>
References: <18214.35373.27736.378763@notabene.brown>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

At 09:34 PM 10/29/2007, Neil Brown wrote:
>
>Someone mentioned to me that if you configure nfs-utils without
>TCP_WRAPPERS, the man pages still say it is available.
>This sort of thing has bothered me on and off before so I thought I
>would do something about it.  i.e. modify the man pages based on the
>config.

I think it would be better to add some words to the effect that the
TCP_WRAPPERS support may not be available on all installs. People
do "man foo" on all kinds of systems (including googling), not just the
one that they're actually running "foo" on. So making it conditional
will serve more to confuse than clarify.

Besides, the text just says to add the relevant hosts to /etc/hosts.allow.
This is harmless, and might even be a good idea. Just change the verbs
from "is" to "may be" and "have" to "may have".

So I say don't drop the text.

Tom.

>
>The following git-patch does this, but I would welcome review as I'm
>not a very experiences automake hacker.
>
>Running "autogen.sh" reports:
>
>utils/mountd/Makefile.am:29: `%'-style pattern rules are a GNU make extension
>utils/statd/Makefile.am:66: `%'-style pattern rules are a GNU make extension
>
>
>Should we care?  Is there a better way?
>
>NeilBrown
>
>(patch can be cherry-picked from git://neil.brown.name/nfs-utils/)
>
>>From be806a06d414603e0930c61d1576d47f46ff064c Mon Sep 17 00:00:00 2001
>From: Neil Brown <neilb@suse.de>
>Date: Tue, 30 Oct 2007 12:18:34 +1100
>Subject: [PATCH] Make man pages configurable and exclude TCP_WRAPPERS 
>notes where appropriate.
>
>This patch makes mountd.man and statd.man able to be modified based on
>configuration, and removes the TCP_WRAPPERS section when that feature
>is not configured in.
>---
> aclocal/tcp-wrappers.m4                    |    1 +
> utils/mountd/Makefile.am                   |   10 ++++++++++
> utils/mountd/{mountd.man => mountd.man.in} |    2 ++
> utils/statd/Makefile.am                    |   10 ++++++++++
> utils/statd/{statd.man => statd.man.in}    |    2 ++
> 5 files changed, 25 insertions(+), 0 deletions(-)
> rename utils/mountd/{mountd.man => mountd.man.in} (99%)
> rename utils/statd/{statd.man => statd.man.in} (99%)
>
>diff --git a/aclocal/tcp-wrappers.m4 b/aclocal/tcp-wrappers.m4
>index 35ac8e0..d76c65d 100644
>--- a/aclocal/tcp-wrappers.m4
>+++ b/aclocal/tcp-wrappers.m4
>@@ -51,4 +51,5 @@ AC_DEFUN([AC_TCP_WRAPPERS],[
>   AC_SUBST(LIBWRAP)
>   AC_SUBST(HAVE_LIBWRAP)
>   AC_SUBST(HAVE_TCP_WRAPPER)
>+  AM_CONDITIONAL(USE_TCP_WRAPPERS, [test $HAVE_TCP_WRAPPER = 1])
> ])
>diff --git a/utils/mountd/Makefile.am b/utils/mountd/Makefile.am
>index 1e76cf8..63a441b 100644
>--- a/utils/mountd/Makefile.am
>+++ b/utils/mountd/Makefile.am
>@@ -19,6 +19,16 @@ mountd_CPPFLAGS = $(AM_CPPFLAGS) $(CPPFLAGS) \
> 
> MAINTAINERCLEANFILES = Makefile.in
> 
>+MAN_SED =
>+if USE_TCP_WRAPPERS
>+MAN_SED += -e 's/USE_TCP_WRAP/yes/'
>+else
>+MAN_SED += -e 's/USE_TCP_WRAP/no/'
>+endif
>+
>+%.man : %.man.in
>+	sed $(MAN_SED) < $< > $@
>+
> #######################################################################
> # The following allows the current practice of having
> # daemons renamed during the install to include RPCPREFIX
>diff --git a/utils/mountd/mountd.man b/utils/mountd/mountd.man.in
>similarity index 99%
>rename from utils/mountd/mountd.man
>rename to utils/mountd/mountd.man.in
>index 4276663..6ed1bef 100644
>--- a/utils/mountd/mountd.man
>+++ b/utils/mountd/mountd.man.in
>@@ -166,6 +166,7 @@ the server. Note that the 'primary' group id is 
>not affected so a
> command on the client will still be effective.  This function requires
> a Linux Kernel with version at least 2.6.21.
> 
>+.if 'USE_TCP_WRAP'no' .ig
> .SH TCP_WRAPPERS SUPPORT
> This
> .B rpc.mountd
>@@ -187,6 +188,7 @@ For further information please have a look at the
> and
> .BR hosts_access (5)
> manual pages.
>+..
> 
> .SH SEE ALSO
> .BR rpc.nfsd (8),
>diff --git a/utils/statd/Makefile.am b/utils/statd/Makefile.am
>index 8a3ba4e..2efb9f9 100644
>--- a/utils/statd/Makefile.am
>+++ b/utils/statd/Makefile.am
>@@ -56,6 +56,16 @@ MAINTAINERCLEANFILES = Makefile.in
> 
> CLEANFILES = $(GENFILES)
> 
>+MAN_SED =
>+if USE_TCP_WRAPPERS
>+MAN_SED += -e 's/USE_TCP_WRAP/yes/'
>+else
>+MAN_SED += -e 's/USE_TCP_WRAP/no/'
>+endif
>+
>+%.man : %.man.in
>+	sed $(MAN_SED) < $< > $@
>+
> #######################################################################
> # The following allows the current practice of having
> # daemons renamed during the install to include RPCPREFIX
>diff --git a/utils/statd/statd.man b/utils/statd/statd.man.in
>similarity index 99%
>rename from utils/statd/statd.man
>rename to utils/statd/statd.man.in
>index e8be9f3..d30159c 100644
>--- a/utils/statd/statd.man
>+++ b/utils/statd/statd.man.in
>@@ -144,6 +144,7 @@ to print out version information and exit.
> 
> 
> 
>+.if 'USE_TCP_WRAP'no' .ig
> .SH TCP_WRAPPERS SUPPORT
> This
> .B rpc.statd
>@@ -165,6 +166,7 @@ For further information please have a look at the
> and
> .BR hosts_access (5)
> manual pages.
>+..
> 
> .SH SIGNALS
> .BR SIGUSR1
>-- 
>1.5.3.4
>
>
>-------------------------------------------------------------------------
>This SF.net email is sponsored by: Splunk Inc.
>Still grepping through log files to find problems?  Stop.
>Now Search log events and configuration files using AJAX and a browser.
>Download your FREE copy of Splunk now >> http://get.splunk.com/
>_______________________________________________
>NFS maillist  -  NFS@lists.sourceforge.net
>https://lists.sourceforge.net/lists/listinfo/nfs

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
