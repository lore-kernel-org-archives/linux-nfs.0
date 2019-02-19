Return-Path: <SRS0=cCtV=Q2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9ED14C43381
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 15:38:59 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 66B86208E4
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 15:38:59 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725991AbfBSPi6 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Feb 2019 10:38:58 -0500
Received: from fieldses.org ([173.255.197.46]:46994 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726206AbfBSPi6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 19 Feb 2019 10:38:58 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 363491C9D; Tue, 19 Feb 2019 10:38:58 -0500 (EST)
Date:   Tue, 19 Feb 2019 10:38:58 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Gefei Li <gefeili.2013@gmail.com>
Cc:     linux-nfs@vger.kernel.org
Subject: Re: linux NFS client lock file cannot get a expected response
Message-ID: <20190219153858.GB19054@fieldses.org>
References: <CANidX5RGLuvdS82TpxuagUsA4DmUochDv2AwX7rwHdD-q+Khbg@mail.gmail.com>
 <20190218202146.GB5879@fieldses.org>
 <CANidX5RjDwJ=yN=aG_D+pQ4fzJ-gXrdqbmwin9eOkyerCU6QRA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANidX5RjDwJ=yN=aG_D+pQ4fzJ-gXrdqbmwin9eOkyerCU6QRA@mail.gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Feb 19, 2019 at 10:09:25AM +0800, Gefei Li wrote:
> Thanks a lot for your reply! I tried to capture and analyse the
> network packets with wireshark and find that a NFS4ERR_LOCKED(10012)
> replied in my experiment 2.2(open with O_SYNC and write) Write
> response. Does this mean that my NFS server uses mandatory locking?

Yes.  I think that's expected for Windows.

> But something unexpected is that an EAGAIN(Resource temporarily
> unavailable) returned in user space, I think an EACCES/EIO is better
> for locked situations, what's your idea about this?

I don't know.

EAGAIN is what fcntl returns when there's a conflicting lock.  It
suggests that retrying might work, while EIO and EACCES suggest that the
failure is permanent.

In the case of linux mandatory locks (see the "mandatory locking"
section in fcntl(2)), read and write block unless you open with
O_NONBLOCK, in which case they return EAGAIN.  Blocking would be more
complicated for the NFS client as all it could do would be to retry the
write repeatedly.

> >> You're checking the file content on the server somehow?
> I close my lock program in my first shell, and check from both
> server-side(use notepad to view the file) and client-side(cat/vim to
> view the file), the file content remained unchanged.

Got it.

--b.
