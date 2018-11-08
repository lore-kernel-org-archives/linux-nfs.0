Return-Path: <SRS0=MTBG=NT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DA1FAC32789
	for <linux-nfs@archiver.kernel.org>; Thu,  8 Nov 2018 13:09:04 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A61472081D
	for <linux-nfs@archiver.kernel.org>; Thu,  8 Nov 2018 13:09:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A61472081D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726571AbeKHWo2 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 8 Nov 2018 17:44:28 -0500
Received: from mx1.redhat.com ([209.132.183.28]:42332 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726421AbeKHWo2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 8 Nov 2018 17:44:28 -0500
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 68D3530024BD;
        Thu,  8 Nov 2018 13:09:03 +0000 (UTC)
Received: from coeurl.usersys.redhat.com (ovpn-123-119.rdu2.redhat.com [10.10.123.119])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 324DE272B4;
        Thu,  8 Nov 2018 13:09:03 +0000 (UTC)
Received: by coeurl.usersys.redhat.com (Postfix, from userid 1000)
        id DC49220678; Thu,  8 Nov 2018 08:09:02 -0500 (EST)
Date:   Thu, 8 Nov 2018 08:09:02 -0500
From:   Scott Mayhew <smayhew@redhat.com>
To:     Steve Dickson <SteveD@redhat.com>
Cc:     jlayton@kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [nfs-utils PATCH RFC 6/7] nfsdcld: add /etc/nfs.conf support
Message-ID: <20181108130902.GF7766@coeurl.usersys.redhat.com>
References: <20181106183620.18609-1-smayhew@redhat.com>
 <20181106183620.18609-7-smayhew@redhat.com>
 <6c30eb21-7be7-accc-78f7-e2544ed46011@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6c30eb21-7be7-accc-78f7-e2544ed46011@RedHat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Thu, 08 Nov 2018 13:09:03 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, 08 Nov 2018, Steve Dickson wrote:

> 
> 
> On 11/6/18 1:36 PM, Scott Mayhew wrote:
> > Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> > ---
> >  nfs.conf                  |  4 ++++
> >  utils/nfsdcld/nfsdcld.c   | 13 +++++++++++++
> >  utils/nfsdcld/nfsdcld.man | 15 +++++++++++++++
> >  3 files changed, 32 insertions(+)
> > 
> > diff --git a/nfs.conf b/nfs.conf
> > index 0d0ec9b..2157b9c 100644
> > --- a/nfs.conf
> > +++ b/nfs.conf
> > @@ -33,6 +33,10 @@
> >  # state-directory-path=/var/lib/nfs
> >  # ha-callout=
> >  #
> > +#[nfsdcld]
> Staring very recently, all sections are now un-commented

Okay, I see that now.

>  
> > +# debug=0
> > +# storagedir=/var/lib/nfs/nfsdcld
> Does this also need a  
>    # pipefsdir=/var/lib/nfs/rpc_pipefs
> 
> Or are you grabbing that from the [general] section?

Yep, that comes from the general section, just like the other pipefs
users.

-Scott

> 
> steved.
> > +#
> >  #[nfsdcltrack]
> >  # debug=0
> >  # storagedir=/var/lib/nfs/nfsdcltrack
> > diff --git a/utils/nfsdcld/nfsdcld.c b/utils/nfsdcld/nfsdcld.c
> > index 272c7c5..313c68f 100644
> > --- a/utils/nfsdcld/nfsdcld.c
> > +++ b/utils/nfsdcld/nfsdcld.c
> > @@ -45,6 +45,7 @@
> >  #include "cld-internal.h"
> >  #include "sqlite.h"
> >  #include "../mount/version.h"
> > +#include "conffile.h"
> >  
> >  #ifndef DEFAULT_PIPEFS_DIR
> >  #define DEFAULT_PIPEFS_DIR NFS_STATEDIR "/rpc_pipefs"
> > @@ -640,6 +641,7 @@ main(int argc, char **argv)
> >  	char *progname;
> >  	char *storagedir = CLD_DEFAULT_STORAGEDIR;
> >  	struct cld_client clnt;
> > +	char *s;
> >  
> >  	memset(&clnt, 0, sizeof(clnt));
> >  
> > @@ -653,6 +655,17 @@ main(int argc, char **argv)
> >  	xlog_syslog(0);
> >  	xlog_stderr(1);
> >  
> > +	conf_init_file(NFS_CONFFILE);
> > +	s = conf_get_str("general", "pipefs-directory");
> > +	if (s)
> > +		strlcpy(pipefs_dir, s, sizeof(pipefs_dir));
> > +	s = conf_get_str("nfsdcld", "storagedir");
> > +	if (s)
> > +		storagedir = s;
> > +	rc = conf_get_num("nfsdcld", "debug", 0);
> > +	if (rc > 0)
> > +		xlog_config(D_ALL, 1);
> > +
> >  	/* process command-line options */
> >  	while ((arg = getopt_long(argc, argv, "hdFp:s:", longopts,
> >  				  NULL)) != EOF) {
> > diff --git a/utils/nfsdcld/nfsdcld.man b/utils/nfsdcld/nfsdcld.man
> > index b607ba6..c271d14 100644
> > --- a/utils/nfsdcld/nfsdcld.man
> > +++ b/utils/nfsdcld/nfsdcld.man
> > @@ -163,6 +163,21 @@ Location of the rpc_pipefs filesystem. The default value is
> >  .IX Item "-s storagedir, --storagedir=storage_dir"
> >  Directory where stable storage information should be kept. The default
> >  value is \fI/var/lib/nfs/nfsdcld\fR.
> > +.SH "CONFIGURATION FILE"
> > +.IX Header "CONFIGURATION FILE"
> > +The following values are recognized in the \fB[nfsdcld]\fR section
> > +of the \fI/etc/nfs.conf\fR configuration file:
> > +.IP "\fBstoragedir\fR" 4
> > +.IX Item "storagedir"
> > +Equivalent to \fB\-s\fR/\fB\-\-storagedir\fR.
> > +.IP "\fBdebug\fR" 4
> > +.IX Item "debug"
> > +Setting "debug = 1" is equivalent to \fB\-d\fR/\fB\-\-debug\fR.
> > +.LP
> > +In addition, the following value is recognized from the \fB[general]\fR section:
> > +.IP "\fBpipefs\-directory\fR" 4
> > +.IX Item "pipefs-directory"
> > +Equivalent to \fB\-p\fR/\fB\-\-pipefsdir\fR.
> >  .SH "NOTES"
> >  .IX Header "NOTES"
> >  The Linux kernel NFSv4 server has historically tracked this information
> > 
