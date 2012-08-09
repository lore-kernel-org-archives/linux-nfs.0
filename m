Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:54175 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751114Ab2HICgq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Aug 2012 22:36:46 -0400
Received: by yenl2 with SMTP id l2so1542617yen.19
        for <linux-nfs@vger.kernel.org>; Wed, 08 Aug 2012 19:36:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1344452605.8925.31.camel@lade.trondhjem.org>
References: <1344390577-1602-1-git-send-email-bergwolf@gmail.com> <1344452605.8925.31.camel@lade.trondhjem.org>
From: Peng Tao <bergwolf@gmail.com>
Date: Thu, 9 Aug 2012 10:36:25 +0800
Message-ID: <CA+a=Yy5cTSZy2Hboxt177Tc+8pvkuP_yMmKUFG5c74DpAxHr5w@mail.gmail.com>
Subject: Re: [PATCH 1/2] NFSv41: fix DIO write_io calculation
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Adamson, Andy" <William.Adamson@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 9, 2012 at 3:03 AM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
> On Wed, 2012-08-08 at 09:49 +0800, Peng Tao wrote:
>> pnfs_within_mdsthreshold() is called inside pg_init. We need
>> to set read_io/write_io before that.
>
> Why?
If we don't set read_io/write_io before calling pg_init, we fail
pnfs_within_mdsthreshold() and IO goes to MDS.
A simple test case:
dd if=foo of=/mnt/pnfs/bar bs=10M count=1 oflag=direct

-- 
Thanks,
Tao
