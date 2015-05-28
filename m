Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vn0-f52.google.com ([209.85.216.52]:34057 "EHLO
	mail-vn0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751556AbbE1UuB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 May 2015 16:50:01 -0400
Received: by vnbf129 with SMTP id f129so6183773vnb.1
        for <linux-nfs@vger.kernel.org>; Thu, 28 May 2015 13:50:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150528203332.GD31663@fieldses.org>
References: <cover.1429868795.git.agruenba@redhat.com>
	<8d601ee8babe5239b7926542c713c58502b15e35.1429868795.git.agruenba@redhat.com>
	<20150528203332.GD31663@fieldses.org>
Date: Thu, 28 May 2015 16:50:00 -0400
Message-ID: <CAHQdGtTe9RfxxGU+UzxnT8A1BmhtPQaOB=g6wXpvmHTu6Ho=Jg@mail.gmail.com>
Subject: Re: [RFC v3 36/45] NFSv4: Fix GETATTR bitmap verification
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 28, 2015 at 4:33 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Fri, Apr 24, 2015 at 01:04:33PM +0200, Andreas Gruenbacher wrote:
>> The NFSv4 client sends the server GETATTR requests with different sets of
>> requested attributes depending on the situation.  The requested set of
>> attributes is encoded in a bitmap; the server replies with the set of
>> attributes it could return.  These bitmaps can be several words wide.  The
>> bitmap returned by the server is a subset of the bitmap sent by the client.
>>
>> While decoding the reply, the client tries to verify the reply bitmap: it
>> checks if any previous, unexpected attributes are left in the same word of the
>> bitmap for each attribute it tries to decode, then it clears the current
>> attribute's bit in the bitmap for the next decode function.
>>
>> The client fails to detect when unexpected attributes are sent after the last
>> expected attribute in each word in the bitmap.
>
> Is it important that the client catch that?

Right. What is the actual problem or bug that this patch is trying to
fix? Why do we care if a buggy server sends us extra info that we
didn't ask for?

Trond
