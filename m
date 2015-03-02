Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:36822 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753919AbbCBP54 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Mar 2015 10:57:56 -0500
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: File Read Returns Non-existent Null Bytes
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAAih9mgZd=-L0Yj=4G4UmqW3fsGKiJtXsK8S8Steme4niguptQ@mail.gmail.com>
Date: Mon, 2 Mar 2015 10:57:43 -0500
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Chris Perl <chris.perl@gmail.com>
Message-Id: <DCF31069-FEF7-4DD8-9FD0-575262181A43@oracle.com>
References: <CAAih9mgvxu+L2Y7yxbHCOKX39Cm5U6ZCd5-HkJUUMFTL9moSwA@mail.gmail.com> <CAHQdGtSvwbVeTD-ALEU=6MJYts=61o1TaUVN6Vky1nwrKPTJXQ@mail.gmail.com> <CAAih9mhNUK6-eeAxM8VcdTCx3b59ztAVHSd37HiYaJr-AbX_1w@mail.gmail.com> <CAHQdGtS1b7Yjs4QozG1R+wxhxvRbCA85ZNCNQG6-ccyDeg+_gA@mail.gmail.com> <CAAih9mg1CkcTYGGZRwg8YPzEkZeqB686s+difvoBHFKfC=VD=g@mail.gmail.com> <CAHQdGtTUcP9b7YBk1Wu_HTO9z=TQF=Dfixig3_Cww=VSaxqGDw@mail.gmail.com> <CAAih9mijyXYSQ6=ckg3J-Kje1fhdjQFVTyB6KvoKYfFbW9cfLQ@mail.gmail.com> <CAHQdGtR7pZz2OsGbMi0cM9MoqmEFWtaStgWwBfSoSebkYmTcMg@mail.gmail.com> <CAAih9miZ8SA2EMz6OkAuLhDox8MLEKpXB7f75LJx5FO9zgm8Rg@mail.gmail.com> <CAHQdGtQyTfTVjHpW3DT6mu0Xk_BwGaFo9xFTbA6ZzeKVe6_HYQ@mail.gmail.com> <20150227224029.GA8750@fieldses.org> <0836BFA3-1F2D-4CD0-AB25-3DBA916D941C@oracle.com> <CAAih9mgZd=-L0Yj=4G4UmqW3fsGKiJtXsK8S8Steme4niguptQ@mail.gmail.com>
To: Chris Perl <cperl@janestreet.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Chris!

Still in the context of deciding what should go in the FAQ, my
comments are below.


On Mar 2, 2015, at 10:19 AM, Chris Perl <cperl@janestreet.com> wrote:

>> I’m in favor of staying more hand-wavy. Otherwise you will end up
>> making promises you don’t intend to keep ;-)
> 
> FWIW, I'm in favor of at least some specifics.  Something stating that
> the results of reading from a file while another client holds it open
> for write are undefined (point 3 of what was already proposed).

The language has to be very careful.

Opens for write are used frequently and by themselves do not cause
any damage. Corruption risk increases when actual writes occur,
followed by reads of the same file on other clients, without a
close and re-open.

Also, any published statement about this could lock us into a
particular behavior. That makes it harder to improve or change
(say, to address a bug) in the future.

Specifics can be discussed on the mailing list on a case-by-case
basis. The specifics depend on a bunch of things, for example:

 - which clients are in play
 - which NFS version is in use (delegations and open state)
 - whether reading and writing is in the same byte range
 - whether the file size is changing
 - whether O_DIRECT and mapped files are in use

And so on. There could also be real bugs, which would become
apparent after discussion.

A general (and more explicit) warning about write sharing is
appropriate to add. I feel it would be difficult to get the
specifics right.

I could add something to A8 that says “Detailed questions can be
directed to linux-nfs@vger.kernel.org.” Do you feel you got a good
answer from the mailing list?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



