Return-Path: <SRS0=ibFv=Q5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1B8DEC10F00
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 20:16:55 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E6049206BA
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 20:16:54 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726260AbfBVUQy (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 22 Feb 2019 15:16:54 -0500
Received: from fieldses.org ([173.255.197.46]:53898 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725900AbfBVUQy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 22 Feb 2019 15:16:54 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id EE138970; Fri, 22 Feb 2019 15:16:52 -0500 (EST)
Date:   Fri, 22 Feb 2019 15:16:52 -0500
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     Mimi Zohar <zohar@linux.ibm.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-integrity@vger.kernel.org,
        Allison Henderson <allison.henderson@oracle.com>,
        Dmitry Kasatkin <dmitry.kasatkin@gmail.com>
Subject: Re: [PATCH RFC 0/4] IMA on NFS prototype
Message-ID: <20190222201652.GA16191@fieldses.org>
References: <20190214203336.6469.34750.stgit@manet.1015granger.net>
 <1550623002.17768.10.camel@linux.ibm.com>
 <ABC54315-2F2B-4FA7-98A8-28A3FC2092DB@oracle.com>
 <1550665596.17768.32.camel@linux.ibm.com>
 <71608AB6-ED45-43BA-A520-0DC2DA7D1C44@oracle.com>
 <1550764295.17768.108.camel@linux.ibm.com>
 <65FC50F1-0EE6-4A3E-95E4-50D9737D3089@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <65FC50F1-0EE6-4A3E-95E4-50D9737D3089@oracle.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Feb 21, 2019 at 10:58:49AM -0500, Chuck Lever wrote:
> 
> 
> > On Feb 21, 2019, at 10:51 AM, Mimi Zohar <zohar@linux.ibm.com> wrote:
> > 
> > On Thu, 2019-02-21 at 09:49 -0500, Chuck Lever wrote:
> >> 
> >>> On Feb 20, 2019, at 7:26 AM, Mimi Zohar <zohar@linux.ibm.com> wrote:
> >>> 
> >>> On Tue, 2019-02-19 at 22:51 -0500, Chuck Lever wrote:
> >>>>> On Feb 19, 2019, at 7:36 PM, Mimi Zohar <zohar@linux.ibm.com> wrote:
> >>>>> 
> >>>>> Hi Chuck,
> >>>>> 
> >>>>>> EVM is not supported in this prototype. NFS does not support several
> >>>>>> of the xattrs that are protected by EVM: SMACK64, Posix ACLs, and
> >>>>>> Linux file capabilities are not supported, which makes EVM more
> >>>>>> difficult to support on NFS mounts.
> >>>>> 
> >>>>> There's no requirement for all of these xattrs to exist.  If an xattr
> >>>>> does exist, then it is included in the security.evm hmac/signature.
> >>>> 
> >>>> Understood. The issue is that if they exist on a file residing on an NFS server,
> >>>> such xattrs would not be visible to clients. My understanding is that then EVM
> >>>> verification would fail on such files on NFS clients.
> >>>> 
> >>>> We could possibly make EVM work in limited scenarios until such time that
> >>>> the NFS protocol can make those xattrs available to NFS clients. I hope that
> >>>> having only security.ima is useful at least for experimenting and maybe more.
> >>>> 
> >>>> However, if folks think having security.evm also is needed, that is straight-
> >>>> forward... just saying that there are currently other limits in NFS that make a
> >>>> full EVM implementation problematic.
> >>> 
> >>> Thank you for the explanation.  Yes, I think there is a benefit of
> >>> having a file signature, without EVM.
> >> 
> >> It's been pointed out to me that a malicious actor inserted between
> >> an NFS server and an NFS client can concurrently substitute the IMA
> >> signature and a file's content with that of another file on the same
> >> NFS share.
> >> 
> >> This could be used to substitute /etc/group for /etc/passwd, for
> >> example. Both files are unchanged and have verifiable IMA signatures.
> >> The /etc/group file contains a passwd-like entry for root in it, but
> >> without a password field. That would allow the actor to gain root
> >> access on the NFS client.
> >> 
> >> NFS can mitigate this substitution by using Kerberos 5 integrity to
> >> protect wire traffic from tampering. However, a malicious NFS server
> >> could also perform this substitution, and krb5i would not be able to
> >> detect it.
> >> 
> >> I'm wondering if there's a mechanism within IMA's toolset to detect
> >> such a substitution on an NFS client.
> > 
> > This problem isn't limited to NFS, but is a general problem.  The file
> > name is part of the directory information, which would need to be
> > protected all the way up to root. (Dmitry's directory patches protects
> > one level of the directory tree.)
> 
> OK, glad to know NFS is not alone!
> 
> We would need to guarantee that the file's absolute pathname as seen
> by NFS clients is the same as its pathname as seen locally on the NFS
> server. This wasn't true for NFSv3, but is usually true for NFSv4,
> which exposes a pseudofilesystem root -- on many NFSv4 servers this
> looks just like the real local filesystem missing any files that are
> not shared. (NFS folks, feel free to chime in and tell me I'm wrong).

That's very implementation-specific.  Better to say something like "the
pathname seen by the NFS client is the same as that in namespace the
server exports".

--b.
