Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f45.google.com ([209.85.214.45]:35178 "EHLO
        mail-it0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751443AbdBHVyE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Feb 2017 16:54:04 -0500
Received: by mail-it0-f45.google.com with SMTP id 203so111937925ith.0
        for <linux-nfs@vger.kernel.org>; Wed, 08 Feb 2017 13:54:04 -0800 (PST)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: NFS server regression in v4.10-rc7
From: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <20170208213914.GA1863@infradead.org>
Date: Wed, 8 Feb 2017 16:54:02 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <BF7B504A-A68C-45CB-8CA9-990F3AB2F1D6@gmail.com>
References: <1485246161-20874-1-git-send-email-hch@lst.de> <60D0607E-7D01-4F68-A447-071B7DEC6F23@gmail.com> <20170208213914.GA1863@infradead.org>
To: Christoph Hellwig <hch@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Feb 8, 2017, at 4:39 PM, Christoph Hellwig <hch@infradead.org> =
wrote:
>=20
> On Wed, Feb 08, 2017 at 04:27:30PM -0500, Chuck Lever wrote:
>> The test is run like this: "cd /mnt/server/git; make clean; make; =
make test"
>>=20
>> Can anyone else reproduce this failure?
>=20
> What local file system do you use on the server?

I see this with my tmpfs export.


--
Chuck Lever
chucklever@gmail.com



