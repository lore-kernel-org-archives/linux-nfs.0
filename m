Return-Path: <SRS0=XA/Y=QT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AD863C282C4
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Feb 2019 19:44:17 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 78F3620842
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Feb 2019 19:44:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1550000657;
	bh=Ih84IKbPdcyaIieF/Fr47BYGLjrCEb/jJ1TyqICGXwQ=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:List-ID:From;
	b=I+lLrhh65hoX2M+iyzXVUukWawe3NC9HPmw94RQXZidvyGiaNSUPgvyFIGEL4jANo
	 dms6S8QtzHXysYw1u/3VmVKqoTX4IosTZJ4HFLqrhnY1kG2Q7KghtqwmTGtKZoyZD3
	 Xc+nDDpljZ3nTziQgTzbLyR0rtM+HdhgJlmO2bEE=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1732284AbfBLToQ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 12 Feb 2019 14:44:16 -0500
Received: from mail.kernel.org ([198.145.29.99]:43114 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727343AbfBLToQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 12 Feb 2019 14:44:16 -0500
Received: from localhost (5356596B.cm-6-7b.dynamic.ziggo.nl [83.86.89.107])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id A471620842;
        Tue, 12 Feb 2019 19:44:15 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1550000656;
        bh=Ih84IKbPdcyaIieF/Fr47BYGLjrCEb/jJ1TyqICGXwQ=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=o4r57gaOxzpzlmZqR9boW9Q8vcS/5Eor+3gKECtN5GhhfCgxOukiy1asXgT9uvtFy
         MG7/4iO6iWiNM/exMx44sYFeaLKEGttHVpx8MZGXMgq9q5NJmP+ELUtMK1RKnzEAVG
         GUQz7E145FkC3SkohiuXrtJS0Z6XklHVxWJb28MY=
Date:   Tue, 12 Feb 2019 20:44:13 +0100
From:   Greg KH <gregkh@linuxfoundation.org>
To:     Murphy Zhou <jencce.kernel@gmail.com>
Cc:     linux-nfs@vger.kernel.org
Subject: Re: [v5.0-rc3 regression] Oops when starting nfs service
Message-ID: <20190212194413.GC3471@kroah.com>
References: <20190212162157.GA27459@sh-el5.eng.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190212162157.GA27459@sh-el5.eng.rdu2.redhat.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Feb 12, 2019 at 11:21:57AM -0500, Murphy Zhou wrote:
> Hi,
> 
> Starting nfs-server service can crash the kernel since
> commit ff9fb72bc07705c00795ca48631f7fffe24d2c6b
> Author: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Date:   Wed Jan 23 11:28:14 2019 +0100
> 
>     debugfs: return error values, not NULL
> 
> # git describe ff9fb72bc07705c00795ca48631f7fffe24d2c6b
> v5.0-rc2-3-gff9fb72bc077
> 

Be careful with 'git describe', you showed what I applied that patch
against, not what release it showed up in.

This really showed up in 5.0-rc6:

$ git describe --contains ff9fb72bc07705c00795ca48631f7fffe24d2c6b
v5.0-rc6~21^2~3

thanks,

greg k-h
