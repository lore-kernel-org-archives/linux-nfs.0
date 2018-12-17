Return-Path: <SRS0=GOsY=O2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B2AE4C43387
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 22:37:34 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4AB5D20578
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 22:37:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=csiro.au header.i=@csiro.au header.b="RWGbum5r"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731822AbeLQWhc (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 17 Dec 2018 17:37:32 -0500
Received: from act-MTAout4.csiro.au ([150.229.7.41]:10190 "EHLO
        act-MTAout4.csiro.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727597AbeLQWhb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Dec 2018 17:37:31 -0500
X-Greylist: delayed 591 seconds by postgrey-1.27 at vger.kernel.org; Mon, 17 Dec 2018 17:37:29 EST
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple;
  d=csiro.au; i=@csiro.au; q=dns/txt; s=dkim;
  t=1545086249; x=1576622249;
  h=date:from:to:cc:subject:message-id:references:
   mime-version:in-reply-to;
  bh=ljO1n6QXrGd5WgaNqKB4EqCfV3zTH+Z3229Qi1pEq44=;
  b=RWGbum5rHYVMleXyydmabQqTGarvu9/f+FNHxRrAPiq9UtU0QuP0NZth
   PbLEwuOm/IWbbdY3H1pHf3GdP3eVk89wSCO/tdAVj0HfxamOHPYlI6eL3
   Ghifr1M0lMrBAvhC2WHnVzRSVZNn++nVL7TsPWDIOctTUm1b4On1raVfu
   w=;
X-SBRS: 4.0
X-IronPort-Anti-Spam-Filtered: true
X-IronPort-Anti-Spam-Result: =?us-ascii?q?A+EBAAArIhhcjACwBSSwhIATAJKcgDR?=
 =?us-ascii?q?lGQEBAQEBAQEBAQEBAQcBAQEBAQGBUQQBAQEBAQsBgTCCYgqMC44Gl1mBew0?=
 =?us-ascii?q?sgxiBKAKDFSI0CQ0BAwEBAgEBAgICEAEBASZYhT0BAQEBAgE6PwULCxgJFRA?=
 =?us-ascii?q?PSAYOBYMigXkIAalWiiwJAYw0gVc/hCOKYAKhGQcCgiiPJwsYkVKDCJZcgUY?=
 =?us-ascii?q?3gVhsg0CCJw4JjjEsMoEHIYwvAYEeAQE?=
X-IPAS-Result: =?us-ascii?q?A+EBAAArIhhcjACwBSSwhIATAJKcgDRlGQEBAQEBAQEBA?=
 =?us-ascii?q?QEBAQcBAQEBAQGBUQQBAQEBAQsBgTCCYgqMC44Gl1mBew0sgxiBKAKDFSI0C?=
 =?us-ascii?q?Q0BAwEBAgEBAgICEAEBASZYhT0BAQEBAgE6PwULCxgJFRAPSAYOBYMigXkIA?=
 =?us-ascii?q?alWiiwJAYw0gVc/hCOKYAKhGQcCgiiPJwsYkVKDCJZcgUY3gVhsg0CCJw4Jj?=
 =?us-ascii?q?jEsMoEHIYwvAYEeAQE?=
Received: from exch4-cdc.nexus.csiro.au ([IPv6:2405:b000:601:13::247:34])
  by act-ironport-int.csiro.au with ESMTP/TLS/AES256-SHA; 18 Dec 2018 09:27:36 +1100
Received: from mayhem.atnf.CSIRO.AU (130.155.194.144) by
 exch4-cdc.nexus.csiro.au (152.83.247.34) with Microsoft SMTP Server (TLS) id
 15.0.1395.4; Tue, 18 Dec 2018 09:27:36 +1100
Date:   Tue, 18 Dec 2018 09:27:30 +1100
From:   Vincent McIntyre <vincent.mcintyre@csiro.au>
To:     Chuck Lever <chuck.lever@oracle.com>
CC:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: mount option timeo - in deciseconds, or seconds?
Message-ID: <20181217222730.fysi2krs7siblihi@mayhem.atnf.CSIRO.AU>
References: <20181215025034.j5zyfytvxqt35woz@mayhem.atnf.CSIRO.AU>
 <8EE078EE-CE10-4316-B447-F005B2034D69@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <8EE078EE-CE10-4316-B447-F005B2034D69@oracle.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Originating-IP: [130.155.194.144]
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Dec 17, 2018 at 10:11:34AM -0500, Chuck Lever wrote:
> Hi Vincent-
> 
> 
> > On Dec 14, 2018, at 9:50 PM, Vincent McIntyre <vincent.mcintyre@csiro.au> wrote:
> > 
> > Hi,
> > 
> > I've been trying to figure out why the nfs.man manpage states
> > 
> >  .BI timeo= n
> >  The time in deciseconds (tenths of a second) the NFS client waits for a
> >  response before it retries an NFS request.
> > 
> > Can someone who actually understands NFS enlighten me?
> > Here's where I'm up to.
> > 
> > I looked in the upstream git.
> > The 'deciseconds' has been in there since the start of git history
> > (2007, commit id 16db99b56a532bf56fa27618a6ef30763cd9006f).
> > But is it (still) correct?
> > 
> > Unfortunately I can't see a direct use of the 'timeo' field
> > of the NFS data structure so the answer is not easily found.
> 
> The "timeo" mount option is not used by the mount.nfs command.
> It is passed to the kernel, which treats it just as the man
> page says.

Thanks Chuck.
I did eventually figure this out but forgot to follow up here.

> The code you excerpt below implements the "retry" mount option.
> 

doh. Thanks for pointing that out.

Kind regards
Vince
