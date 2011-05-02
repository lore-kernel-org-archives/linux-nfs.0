Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:63436 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756136Ab1EBO3M convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 May 2011 10:29:12 -0400
Received: by ywj3 with SMTP id 3so1910039ywj.19
        for <linux-nfs@vger.kernel.org>; Mon, 02 May 2011 07:29:11 -0700 (PDT)
In-Reply-To: <20110502140750.GA10885@fieldses.org>
References: <BANLkTi=X0VtcSecmEwzPBTqk3L154aj+2Q@mail.gmail.com>
	<20110502140750.GA10885@fieldses.org>
Date: Mon, 2 May 2011 16:29:11 +0200
Message-ID: <BANLkTinTu8XVmxkUUhJby8=DNY4sZF5VAQ@mail.gmail.com>
Subject: Re: How does NFS handle notify?
From: Stef Bon <stefbon@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Ok,

so as I understand NFS does not support it yet. I thought it does.

Are you interested when I set up a project to work on the VFS to make
it possible to
make the mounted fs notified (by the VFS) that a  notify watch is set
(or removed)?
I guess the developers of cifs are interested too, and me, as
developer of a FUSE fs.

Stef



2011/5/2 J. Bruce Fields <bfields@fieldses.org>:
> On Sun, May 01, 2011 at 11:33:32AM +0200, Stef Bon wrote:
>> Mentioned there - and I agree - that when developing support for
>> notify on mounted filesystems you need to have one base (in VFS), and
>> a part which is handled by the (mounted) fs self.
>>
>> So here my question, how does NFS handle notify??
>
> No.  It might be possible with new features in the 4.1 version of the
> protocol (http://tools.ietf.org/html//rfc5661#section-10.9).
>
> --b.
>
