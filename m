Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aa.linuxbox.com ([134.215.213.37]:4249 "EHLO aa.linuxbox.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755519Ab2CXQx4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 24 Mar 2012 12:53:56 -0400
Date: Sat, 24 Mar 2012 12:53:47 -0400 (EDT)
From: "Matt W. Benjamin" <matt@linuxbox.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>, Boaz Harrosh <bharrosh@panasas.com>
Message-ID: <275611967.8.1332608027370.JavaMail.root@thunderbeast.private.linuxbox.com>
In-Reply-To: <1332607503.25346.2.camel@lade.trondhjem.org>
Subject: Re: unlink within an open directory stream
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I don't think anything is.  Or, people originally reported the behavior against knfsd.

Matt

----- "Trond Myklebust" <Trond.Myklebust@netapp.com> wrote:

> On Sat, 2012-03-24 at 12:34 -0400, Matt W. Benjamin wrote:
> > Hi,
> > 
> > Folks testing linux nfs + Ganesha with bonnie++ have noticed the
> issue described here (but I didn't see traffic on this list):
> > 
> > http://bugs.centos.org/view.php?id=5496
> > https://bugzilla.redhat.com/show_bug.cgi?id=789452
> > 
> > Ie, an application which unlinks on an open (nfs) directory stream,
> and continues to read and unlink progressively, will generally not see
> all the entries originally in the stream.  Reopening the stream ives
> the "correct" result.  So, apparently older clients were more
> forgiving, as mentioned in the links.  Is the current behavior one the
> client is intending?
> > 
> > Thanks,
> > 
> > Matt
> 
> What is so particular about the ganesha readdir implementation?
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com

-- 
Matt Benjamin
The Linux Box
206 South Fifth Ave. Suite 150
Ann Arbor, MI  48104

http://linuxbox.com

tel. 734-761-4689
fax. 734-769-8938
cel. 734-216-5309
