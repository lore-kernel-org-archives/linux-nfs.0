Return-Path: <SRS0=PHUf=OT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 58E25C04EB8
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 17:55:50 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1D00C2081F
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 17:55:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="AHJficDh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1D00C2081F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728349AbeLJRzt (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 10 Dec 2018 12:55:49 -0500
Received: from mail-oi1-f174.google.com ([209.85.167.174]:33365 "EHLO
        mail-oi1-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727264AbeLJRzt (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2018 12:55:49 -0500
Received: by mail-oi1-f174.google.com with SMTP id c206so9730192oib.0
        for <linux-nfs@vger.kernel.org>; Mon, 10 Dec 2018 09:55:48 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=PP2Fepdt6fRrkeiX2e7TojUjKkwLin+dPQpcNhtY5Vg=;
        b=AHJficDhrfJUWs9J0vURv7iDL5LZsFbWup5hRvFsHkZM6Uak8Cf/7SXIC039WYimve
         DsdIgkVtqJmhAA9RNiIsNDEEbelPtOhCFPHuL3qC5TmFbkx6D0ACzL/+fPx4BDjN8kMi
         InMTV1MeACS/QyDdpnHbGcPl6Nly57pNooBK8ePDENpA/zIfJyQ4/1yf2D9FCYTCvZMu
         Xgtj3cBLUNSuFnQCBcnnXbG8O+nLvI6SPAin1YQUzIvW2LhpCDCC8l2DbL54jC3n3MKE
         e3pA5iDMll+TjXG/WgmnKqwa0suM15Ttu1bx1x9LmBRvUIKtqAfav9seyR1t4z19TStJ
         almw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=PP2Fepdt6fRrkeiX2e7TojUjKkwLin+dPQpcNhtY5Vg=;
        b=plf2UO9kxAeo0taWpcGJmVS7Vny9jwS0DcwWPI60a6gKmBPUb2c6R2l7wGHBZPqWOv
         51VK85UJL150iCGtt1UkeEQjnavML8ARsk3PtMeMEtNe4FnqKj1qxV+J5hZy4w8A0JEN
         n+QZArCHxua/SfeHmn/ANthKhlSUiDNcnn2+/V8ax69Lssy5TBLoZctVAfUhNu5TU+nS
         qF4CHvIbJkesIzMNVHEaOK6Tl7PaS1zbZXwyxrXhoLaL2ghf67Rj9VsadGMACWZc0K1X
         crFYEO3SUh2j196wfM6STYJrae9KysoCV0GD7CnDq1OhxUJKXOwfTwYkwrB1W8dPSALg
         GwrA==
X-Gm-Message-State: AA+aEWYKwjTfHCKf397gh3kh3vIy5I7WuSMrFtCHH/mEuHJ2A9uV+UC2
        dhd7DMVGSbgR1KOa54vfFn9/sg==
X-Google-Smtp-Source: AFSGD/Vi/wJoE8MMsW8nu5f9efLYWqcRMsJtZLcbCnp1wz6v7HFt65/WZjP4CguoMZD0OFAeeo0S7A==
X-Received: by 2002:aca:641:: with SMTP id 62mr7818100oig.63.1544464548309;
        Mon, 10 Dec 2018 09:55:48 -0800 (PST)
Received: from ziepe.ca ([217.140.111.136])
        by smtp.gmail.com with ESMTPSA id i12sm912429otc.48.2018.12.10.09.55.47
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 10 Dec 2018 09:55:47 -0800 (PST)
Received: from jgg by jggl.ziepe.ca with local (Exim 4.90_1)
        (envelope-from <jgg@ziepe.ca>)
        id 1gWPmV-0001dy-27; Mon, 10 Dec 2018 10:55:47 -0700
Date:   Mon, 10 Dec 2018 10:55:47 -0700
From:   Jason Gunthorpe <jgg@ziepe.ca>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     anna.schumaker@netapp.com, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 00/24] NFS/RDMA client for next
Message-ID: <20181210175547.GC5334@ziepe.ca>
References: <20181210161723.4198.51071.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181210161723.4198.51071.stgit@manet.1015granger.net>
User-Agent: Mutt/1.9.4 (2018-02-28)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Dec 10, 2018 at 11:29:17AM -0500, Chuck Lever wrote:
> Hi Anna, I'd like to see these patches merged into next.
> 
> There have been several regressions related to the ->send_request
> changes merged into v4.20. As a result, this series contains some
> fixes and clean-ups that resulted from testing and close code
> audit while working on those regressions.
> 
> The soft IRQ warnings and DMAR faults that I observed with krb5
> flavors on NFS/RDMA are resolved by a prototype fix that delays
> the xprt_wake_pending_tasks call at disconnect. This fix is not
> ready yet and thus does not appear in this series.
> 
> However, use of Kerberos seems to trigger a lot of connection loss.
> The dynamic rpcrdma_req allocation patches that were in this series
> last time have been dropped because they made it even worse.
> 
> "xprtrdma: Prevent leak of rpcrdma_rep objects" is included in this
> series for convenience. Please apply that to v4.20-rc. Thanks!
> 
> Changes since v2:
> - Rebased on v4.20-rc6 to pick up recent fixes
> - Patches related to "xprtrdma: Dynamically allocate rpcrdma_reqs"
>   have been dropped
> - A number of revisions of documenting comments have been added
> - Several new trace points are introduced
> 
> 
> Changes since v1:
> - Rebased on v4.20-rc4
> - Series includes the full set, not just the RDMA-related fixes
> - "Plant XID..." has been improved, based on testing with rxe
> - The required rxe driver fix is included for convenience
> - "Fix ri_max_segs..." replaces a bogus one-line fix in v1
> - The patch description for "Remove support for FMR" was updated
> 
> 
> Chuck Lever (24):
>       xprtrdma: Prevent leak of rpcrdma_rep objects
>       IB/rxe: IB_WR_REG_MR does not capture MR's iova field

This last patch is already applied to the RDMA tree, please do not
apply it to another tree.

Thanks,
Jason
