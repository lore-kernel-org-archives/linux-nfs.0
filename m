Return-Path: <SRS0=XA/Y=QT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72A32C282C4
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Feb 2019 15:05:03 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3ECAF217D9
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Feb 2019 15:05:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1549983903;
	bh=FAdfggzp9gf7H5uS84woJlhzeNvXWOAJKR/Tq1X2SnU=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:List-ID:From;
	b=PL2PbPm6wure39SsPj+bJh5P1HI+ksij9yMBs04DlOk+a1jcYvCQZBlz5W5QGaJf0
	 syEax7HO2vyJDSJRogiIEuNdf38eT+bD2H1BXA4FnB7z2sHpSbcf05cl4oGgBU+j5A
	 NYQNhpo+ivPdz2LFhbGUtYqrTjjf4KeUn6Vb9q+8=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728579AbfBLPFC (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 12 Feb 2019 10:05:02 -0500
Received: from mail.kernel.org ([198.145.29.99]:53980 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726748AbfBLPFC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 12 Feb 2019 10:05:02 -0500
Received: from localhost (5356596B.cm-6-7b.dynamic.ziggo.nl [83.86.89.107])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 831CF21773;
        Tue, 12 Feb 2019 15:05:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1549983901;
        bh=FAdfggzp9gf7H5uS84woJlhzeNvXWOAJKR/Tq1X2SnU=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=n9ddRDK/AE8O88H07Qz38hJjJ0idaf3ulTWvubNnFSgpjL7YbvEs81mZX+WHLASCY
         RGHrzDBNGm4AYGSgY6XdTvA7USyPo8twazIEeEt3/PGfU2tI75ddt4pA93/mm3vdJH
         h3St4uaEiCYROhiNCkzoMpW8RDQZJvy1X/sCv2j8=
Date:   Tue, 12 Feb 2019 16:04:59 +0100
From:   Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To:     David Howells <dhowells@redhat.com>
Cc:     linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        mhiramat@kernel.org, bigeasy@linutronix.de
Subject: Re: Oops in rpc_clnt_debugfs_register() from debugfs change
Message-ID: <20190212150459.GA19188@kroah.com>
References: <20190212144214.GA17111@kroah.com>
 <19914.1549970944@warthog.procyon.org.uk>
 <14223.1549981874@warthog.procyon.org.uk>
 <20190212143720.GA16380@kroah.com>
 <21212.1549983454@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <21212.1549983454@warthog.procyon.org.uk>
User-Agent: Mutt/1.11.3 (2019-02-01)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Feb 12, 2019 at 02:57:34PM +0000, David Howells wrote:
> Greg Kroah-Hartman <gregkh@linuxfoundation.org> wrote:
> 
> > -	if (!xprt->debugfs) {
> > +	if (IS_ERR_OR_NULL(xprt->debugfs)) {
> 
> That works, though I don't much like the idea of there being an error there.
> 
> Looking in rpc_xprt_debugfs_register() there are two now-dodgy looking checks
> on the result of debugfs calls.

now-dodgy checks are fine.  Well, they shouldn't matter, I've sent a
patch that just gets rid of those checks.

Ideally no one should need to check of debugfs is ok or not, the fact
that these functions keep getting called is a bit odd, I can look into
that some more, it shouldn't be needed...

thanks,

greg k-h
