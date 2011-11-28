Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:8916 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751427Ab1K1Os1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Nov 2011 09:48:27 -0500
Message-ID: <4ED39F2D.7050508@RedHat.com>
Date: Mon, 28 Nov 2011 09:48:13 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: nfs-utils and libnfsidmap
References: <CAGue13qasD7m+dj3PdA+p5jfJQU_Eq0r+Z9QqtvOSnadFmWJeg@mail.gmail.com> <20111123201345.GA1044@fieldses.org>
In-Reply-To: <20111123201345.GA1044@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/23/2011 03:13 PM, J. Bruce Fields wrote:
> On Wed, Nov 23, 2011 at 08:54:06PM +0100, Tigran Mkrtchyan wrote:
>> Hi All,
>>
>> today was tracing a bug in nfs-utils/libnfsidmap and after a log
>> debugging located it and
>> finally realized that it's already fixed by Steve Dickson (
>> http://git.linux-nfs.org/?p=steved/nfs-utils.git;a=commit;h=d22ef3f525d71b565fcc688557273a6cabeeb71a
>> ). Nevertheless during
>> this procedure it turned out that there is quite some code duplicated
>> between nfs-utils and
>> libnfsidmap.
>>
>> Questions:
>>    a) why nfs-utils duplicates some part of libnfsidmap and still depends o it
>>    b) is there readon for code duplication? Licensing or so
>>    c) what ww need to do to get rid of duplication
>>
>> I expect the answer of 'c' will contain something like time and man power.
>> I am volunteering to to pend some time on it.
> 
> I doubt there's any real reason for duplication.
Just curious as to what code we are talking about...

> 
> Probably libnfsidmap should be part of nfs-utils, actually.
I guess we could roll the libnfsidmap git tree into the nfs-utils
tree... if that make senses... It probably would simply things.. 

> 
> And maybe we don't need it at all--the original reason to split out
> libnfsidmap was to share the code with libacl, so the posix getfacl
> command could do v4->posix acl mapping, but those patches never made it
> upstream.
So you don't think this will every happen?

steved.

> 
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
