Return-Path: <SRS0=aRlV=NH=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08AB4C46475
	for <linux-nfs@archiver.kernel.org>; Sat, 27 Oct 2018 13:26:29 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AE61020828
	for <linux-nfs@archiver.kernel.org>; Sat, 27 Oct 2018 13:26:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="a8ONUM7G"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AE61020828
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728667AbeJ0WH1 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 27 Oct 2018 18:07:27 -0400
Received: from bombadil.infradead.org ([198.137.202.133]:48592 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728252AbeJ0WH1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Oct 2018 18:07:27 -0400
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
        :References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
        Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
        List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
         bh=ZmsPIkP8QazkZtCNPvMs1ZMRKCCa6202bIrUPV4WKPo=; b=a8ONUM7GBgWqHKp7P/R1LqJyp
        bULAUMEpLosrnzvu5kCDiOUFwxusVgwso/4YLTDjyth7Brbzy+swC+xxwmSjitmdHmgljXQ458dRs
        0Hmi4AlwvSyKttzeKruY2/o7EEW4PElOoHp3TVmTv/fKEbYkMTlnCUyjPDPiFbfe8Hwymiblmljtp
        D7JFRVlU/Ozl7mUoeVkio5NmJdCxcAnRf92v6yPKY5ppVmKeYkk8mAJp/GVZV3hUcfnkEJPCqNrvG
        IRHVf9c8wx4TUOzkDefj/cHTkjJ2bxKj8b5VvoOZ1COG2iZ50j4/r5dkaX+oz/BJYTzT+ZUIxIQvt
        Sp8hHUIng==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
        id 1gGObg-0005qp-Ai; Sat, 27 Oct 2018 13:26:24 +0000
Date:   Sat, 27 Oct 2018 06:26:24 -0700
From:   Matthew Wilcox <willy@infradead.org>
To:     Jeff Layton <jlayton@kernel.org>
Cc:     Olga Kornievskaia <olga.kornievskaia@gmail.com>,
        trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: Re: [PATCH v4 11/11] NFS: replace cross device check in
 copy_file_range
Message-ID: <20181027132624.GA25444@bombadil.infradead.org>
References: <20181026201057.36899-1-olga.kornievskaia@gmail.com>
 <20181026201057.36899-13-olga.kornievskaia@gmail.com>
 <7ef50e2c6b11ae80518db75efc35b2f96c9e4d32.camel@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7ef50e2c6b11ae80518db75efc35b2f96c9e4d32.camel@kernel.org>
User-Agent: Mutt/1.9.2 (2017-12-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sat, Oct 27, 2018 at 07:08:11AM -0400, Jeff Layton wrote:
> >  
> > -	if (file_in->f_inode->i_sb != file_out->f_inode->i_sb)
> > +	if (file_in->f_op != &nfs4_file_operations)
> >  		return -EXDEV;
> > +	else {
> 
> nit: you don't really need the "else" here since the previous block
> returns
> 
> > +		struct nfs_client *c_in =
> > +			(NFS_SERVER(file_inode(file_in)))->nfs_client;
> > +		if (c_in->cl_minorversion < 2)
> > +			return -EXDEV;
> > +	}

Yeah, but if you don't have the else, then you need to declare the c_in
at the beginning of the function instead of in the new block.  Mind you,
if you do that then:

	c_in = NFS_SERVER(file_inode(file_in))->nfs_client;

fits on one line, so it does look a bit neater.
