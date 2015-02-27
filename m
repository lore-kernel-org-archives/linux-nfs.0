Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:19165 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755307AbbB0Xdi convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Feb 2015 18:33:38 -0500
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: File Read Returns Non-existent Null Bytes
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20150227224029.GA8750@fieldses.org>
Date: Fri, 27 Feb 2015 18:33:24 -0500
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Chris Perl <cperl@janestreet.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Chris Perl <chris.perl@gmail.com>
Message-Id: <0836BFA3-1F2D-4CD0-AB25-3DBA916D941C@oracle.com>
References: <CAAih9mgvxu+L2Y7yxbHCOKX39Cm5U6ZCd5-HkJUUMFTL9moSwA@mail.gmail.com> <CAHQdGtSvwbVeTD-ALEU=6MJYts=61o1TaUVN6Vky1nwrKPTJXQ@mail.gmail.com> <CAAih9mhNUK6-eeAxM8VcdTCx3b59ztAVHSd37HiYaJr-AbX_1w@mail.gmail.com> <CAHQdGtS1b7Yjs4QozG1R+wxhxvRbCA85ZNCNQG6-ccyDeg+_gA@mail.gmail.com> <CAAih9mg1CkcTYGGZRwg8YPzEkZeqB686s+difvoBHFKfC=VD=g@mail.gmail.com> <CAHQdGtTUcP9b7YBk1Wu_HTO9z=TQF=Dfixig3_Cww=VSaxqGDw@mail.gmail.com> <CAAih9mijyXYSQ6=ckg3J-Kje1fhdjQFVTyB6KvoKYfFbW9cfLQ@mail.gmail.com> <CAHQdGtR7pZz2OsGbMi0cM9MoqmEFWtaStgWwBfSoSebkYmTcMg@mail.gmail.com> <CAAih9miZ8SA2EMz6OkAuLhDox8MLEKpXB7f75LJx5FO9zgm8Rg@mail.gmail.com> <CAHQdGtQyTfTVjHpW3DT6mu0Xk_BwGaFo9xFTbA6ZzeKVe6_HYQ@mail.gmail.com> <20150227224029.GA8750@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 27, 2015, at 5:40 PM, bfields@fieldses.org wrote:

> On Thu, Feb 26, 2015 at 08:29:51AM -0500, Trond Myklebust wrote:
>> On Thu, Feb 26, 2015 at 7:41 AM, Chris Perl <cperl@janestreet.com> wrote:
>>>>> Ok, thanks for helping me understand this a little more clearly.  For
>>>>> my own edification, is there somewhere I can find the details where
>>>>> these things are spelled out (or is it just somewhere in rfc1813 that
>>>>> I haven't seen)?
>>>> 
>>>> There is a short description here:
>>>>    http://nfs.sourceforge.net/#faq_a8
>>> 
>>> Yes, thanks.  I had come across that when trying to do a little
>>> research after your initial reply.
>>> 
>>> However, I was hoping for something with a little more detail.  For
>>> example, you said earlier that "the close-to-open cache consistency
>>> model is clear ...", which implied to me that there was a more formal
>>> description somewhere outlining the semantics and constraints.  Or is
>>> it just more of an implementation detail?
>>> 
>>> Also, reading that FAQ entry seems to reinforce my original notion
>>> that a client reading a file that is being updated might get stale
>>> data returned from its cache, but shouldn't get corrupt data returned
>>> from its cache.  Perhaps the FAQ entry should be updated to explicitly
>>> note that corrupt data can be returned?
>>> 
>>> FWIW, I realize that the use case I've given as a reproducer isn't
>>> supported and isn't supposed to work.  I accept that and that is fine.
>>> However, we do run into this problem in "everyday types of file
>>> sharing" (to quote that FAQ).  Sometimes (not very often, but enough
>>> that its annoying), someone will cat a file that is already in their
>>> clients page cache, and it happens to be at just the wrong time,
>>> resulting in corrupt data being read.
>> 
>> If you are saying that we're not making it clear enough that "you
>> ignore these rules at your peril" then, fair enough, I'm sure Chuck
>> would be able to add a line to the faq stating just that.
> 
> Yeah, I don't think that FAQ answer is clear.  It talks a little about
> how close-to-open is implemented but doesn't really state clearly what
> applications can assume.  The first paragraph comes close, but it's
> really just a motivating example.
> 
> A rought attempt, but it feels a little overboard while still
> incomplete:

I’m in favor of staying more hand-wavy. Otherwise you will end up
making promises you don’t intend to keep ;-)

Something like:

> Because NFS is not a cluster or “single system image” filesystem,
> applications must provide proper serialization of reads and writes among multiple clients to ensure correct application behavior and
> prevent corruption of file data. The close-to-open mechanism is not
> adequate in the presence of concurrent opens for write when multiple
> clients are involved.

Plus or minus some word-smithing.

And, let’s consider updating the DATA AND METADATA COHERENCY section
of nfs(5), which contains a similar discussion of close-to-open
cache consistency.


> 	- access from multiple processes on the same client provides the
> 	  same guarantees as on local filesystems.
> 
> 	- access from multiple clients will provide the same guarantees
> 	  as long as no client's open for write overlaps any other open
> 	  from another client.
> 
> 	- if a client does open a file for read while another holds it
> 	  open for write, results of that client's reads are undefined.
> 
> 	- More specifically, a read of a byte at offset X could return a
> 	  byte that has been written to that offset during a concurrent
> 	  write open, or the value stored there at offset X at the start
> 	  of that write open, or 0 if X happened to be past the end of
> 	  file at any point during the concurrent write open.  The
> 	  reader may not assume any relationships among values at
> 	  different offsets or the file size, updates to any of which
> 	  may be seen in any order.
> 
> ?
> 
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



