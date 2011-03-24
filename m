Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:38442 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754435Ab1CXOpQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Mar 2011 10:45:16 -0400
Received: by iyb26 with SMTP id 26so34681iyb.19
        for <linux-nfs@vger.kernel.org>; Thu, 24 Mar 2011 07:45:15 -0700 (PDT)
Date: Thu, 24 Mar 2011 10:45:15 -0400
Message-ID: <AANLkTi=S+gQER_upORoaK6WSMp8++25W6pTDpR7MD9Ec@mail.gmail.com>
Subject: Re: [PATCH 11/12] NFSv4.1: layoutcommit
From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
To: Benny Halevy <bhalevy@panasas.com>
Cc: Fred Isaman <iisaman@netapp.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Benny

int sync is used because the struct writeback_control->sync_mode (an
enum) is assigned.

-->Andy

>> +pnfs_layoutcommit_inode(struct inode *inode, int sync)
>
> "bool sync" makes more sense
