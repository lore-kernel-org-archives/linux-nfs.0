Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36367 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752438AbcCUWsG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Mar 2016 18:48:06 -0400
MIME-Version: 1.0
In-Reply-To: <20160321223627.GA12999@thunk.org>
References: <56F03945.40208@gentoo.org>
	<56F05745.50204@gentoo.org>
	<20160321204041.GA807@fieldses.org>
	<20160321223627.GA12999@thunk.org>
Date: Mon, 21 Mar 2016 23:48:04 +0100
Message-ID: <CALXu0UdPyhBpOb-q-jpVN55d5unAQYXQFSm7HgNKWBH0Q_-gmg@mail.gmail.com>
Subject: Re: Making an interface for alternative data streams
From: Cedric Blancher <cedric.blancher@gmail.com>
To: "Theodore Ts'o" <tytso@mit.edu>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, Richard Yao <ryao@gentoo.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Christoph Hellwig <hch@infradead.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 21 March 2016 at 23:36, Theodore Ts'o <tytso@mit.edu> wrote:
> On Mon, Mar 21, 2016 at 04:40:41PM -0400, J. Bruce Fields wrote:
>> On Mon, Mar 21, 2016 at 04:19:17PM -0400, Richard Yao wrote:
>> > Maybe I should clarify that the idea is to allow read/write/list of
>> > extended attributes via read/write/readdir so that those that want
>> > extended attributes that are alternative data streams can have them. I
>> > do not want to see extended attributes and alternative data streams be
>> > different things.
>>
>> I think there are differences between the two that make this awkward.
>> Does anyone actually use alternative data stream for anything that makes
>> the effort worthwhile?
>
> Windows malware authors *love* to use alternate data streams as a
> place to hide their malware where many security scanners weren't
> looking, and certainly most users won't find.
>
> Does that count?   :-)

Old invalid argument, and Sophos and Symatec look there as well.

If it was a bad idea, why has Linux fs attributes which are almost the
same as O_XATTR except that they use a custom api? Why does Macos have
alternate streams (called forks)? Why did Solaris adopt it long ago
(and still gets support questions about it - just saying before
someone argues that no one uses THAT)?

Ced
-- 
Cedric Blancher <cedric.blancher@gmail.com>
Institute Pasteur
