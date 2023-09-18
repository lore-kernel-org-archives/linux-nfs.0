Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B03EFC46CA1
	for <linux-nfs@archiver.kernel.org>; Mon, 18 Sep 2023 16:52:34 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229476AbjIRQwi (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 18 Sep 2023 12:52:38 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:37876 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S230246AbjIRQwh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Sep 2023 12:52:37 -0400
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 65A9B97
        for <linux-nfs@vger.kernel.org>; Mon, 18 Sep 2023 09:52:32 -0700 (PDT)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6AA60C32782;
        Mon, 18 Sep 2023 14:26:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1695047193;
        bh=OZ7EtXa6Cj+sv94hEw2tEb1OpHdcFfbP9PLHbVokAR4=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=sy0XZphWLk80IJnuhoKEcJuu4VWQrmXh+84tQoMqL9zlkuY6ylXw5jGERC0TduD1Z
         dyvL1iEkHPTrnD4L0kF6u0Zk61teLEBoBT6oFB66TUWeCS/XhIzLtdsmnaKJQ+hoJp
         JRfXPA7Jcg3gmhGqmPynfk30qf0Db2JWgUzBiWurlBcSV/S69RdKBaBg3LnQJEGaIK
         fOYfbztGhuW9Pb9dD45YPrrDAAcPkI8nGLw57SuUqANsK3L5d3hWsdUehUvROPBmgk
         +HxUO+yXKtwzLRaT9lGV3QqLHczFRVB+5QJko0PfYQR3mIIRgO0HeI9w3C45AkW6Lg
         4WADk9VCZk6FQ==
Date:   Mon, 18 Sep 2023 16:26:29 +0200
From:   Christian Brauner <brauner@kernel.org>
To:     Chuck Lever <cel@kernel.org>
Cc:     neilb@suse.de, Chuck Lever <chuck.lever@oracle.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1] SUNRPC: Remove BUG_ON call sites
Message-ID: <20230918-erwidern-unmerklich-246f1fe73529@brauner>
References: <169504668787.134583.4338728458451666583.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <169504668787.134583.4338728458451666583.stgit@manet.1015granger.net>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Sep 18, 2023 at 10:18:30AM -0400, Chuck Lever wrote:
> From: Chuck Lever <chuck.lever@oracle.com>
> 
> There is no need to take down the whole system for these assertions.
> 
> I'd rather not attempt a heroic save here, as some bug has occurred
> that has left the transport data structures in an unknown state.
> Just warn and then leak the left-over resources.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---

Fine by me,
Acked-by: Christian Brauner <brauner@kernel.org>
