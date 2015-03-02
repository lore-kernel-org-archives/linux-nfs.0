Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:41126 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751460AbbCBVQE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Mar 2015 16:16:04 -0500
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: File Read Returns Non-existent Null Bytes
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20150302205850.GG8033@fieldses.org>
Date: Mon, 2 Mar 2015 16:15:50 -0500
Cc: Chris Perl <cperl@janestreet.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Chris Perl <chris.perl@gmail.com>
Message-Id: <3E668056-0C9D-440D-86E5-CCB5AF74D7A7@oracle.com>
References: <CAAih9mg1CkcTYGGZRwg8YPzEkZeqB686s+difvoBHFKfC=VD=g@mail.gmail.com> <CAHQdGtTUcP9b7YBk1Wu_HTO9z=TQF=Dfixig3_Cww=VSaxqGDw@mail.gmail.com> <CAAih9mijyXYSQ6=ckg3J-Kje1fhdjQFVTyB6KvoKYfFbW9cfLQ@mail.gmail.com> <CAHQdGtR7pZz2OsGbMi0cM9MoqmEFWtaStgWwBfSoSebkYmTcMg@mail.gmail.com> <CAAih9miZ8SA2EMz6OkAuLhDox8MLEKpXB7f75LJx5FO9zgm8Rg@mail.gmail.com> <CAHQdGtQyTfTVjHpW3DT6mu0Xk_BwGaFo9xFTbA6ZzeKVe6_HYQ@mail.gmail.com> <20150227224029.GA8750@fieldses.org> <0836BFA3-1F2D-4CD0-AB25-3DBA916D941C@oracle.com> <CAAih9mgZd=-L0Yj=4G4UmqW3fsGKiJtXsK8S8Steme4niguptQ@mail.gmail.com> <DCF31069-FEF7-4DD8-9FD0-575262181A43@oracle.com> <20150302205850.GG8033@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 2, 2015, at 3:58 PM, J. Bruce Fields <bfields@fieldses.org> wrote:

> On Mon, Mar 02, 2015 at 10:57:43AM -0500, Chuck Lever wrote:
>> Hi Chris!
>> 
>> Still in the context of deciding what should go in the FAQ, my
>> comments are below.
>> 
>> 
>> On Mar 2, 2015, at 10:19 AM, Chris Perl <cperl@janestreet.com> wrote:
>> 
>>>> I’m in favor of staying more hand-wavy. Otherwise you will end up
>>>> making promises you don’t intend to keep ;-)
>>> 
>>> FWIW, I'm in favor of at least some specifics.  Something stating that
>>> the results of reading from a file while another client holds it open
>>> for write are undefined (point 3 of what was already proposed).
>> 
>> The language has to be very careful.
>> 
>> Opens for write are used frequently and by themselves do not cause
>> any damage. Corruption risk increases when actual writes occur,
>> followed by reads of the same file on other clients, without a
>> close and re-open.
>> 
>> Also, any published statement about this could lock us into a
>> particular behavior. That makes it harder to improve or change
>> (say, to address a bug) in the future.
>> 
>> Specifics can be discussed on the mailing list on a case-by-case
>> basis. The specifics depend on a bunch of things, for example:
>> 
>> - which clients are in play
>> - which NFS version is in use (delegations and open state)
>> - whether reading and writing is in the same byte range
>> - whether the file size is changing
>> - whether O_DIRECT and mapped files are in use
> 
> These are cases we'd only need to go into if we wanted to give
> *stronger* gaurantees than "all bets are off when you don't serialize
> with write opens", yes?

> And, sure, that would be interesting, but I think Chris is just asking
> for a clearer statement of that basic requirement.

I read Chris’s e-mail as a request for more detail in the answer
I proposed before. Maybe I’m wrong.

Is this not sufficient:

“Because NFS is not a cluster or “single system image” filesystem,
applications must provide proper serialization of reads and writes
among multiple clients to ensure correct application behavior and
prevent corruption of file data. The close-to-open mechanism is not
adequate in the presence of concurrent opens for write when multiple
clients are involved.”

Perhaps the “presence of concurrent opens for write” should be
replaced with “presence of concurrent writes.” But what else needs
to be said?

> He's far from the first to assume that the results you'd get from
> overlapping opens would be out of date but still reasonable in some
> sense, and the FAQ could use a stronger statement that that's not the
> case.

No disagreement there. I’m just trying to figure out the right
level of detail.

> --b.
> 
>> 
>> And so on. There could also be real bugs, which would become
>> apparent after discussion.
>> 
>> A general (and more explicit) warning about write sharing is
>> appropriate to add. I feel it would be difficult to get the
>> specifics right.
>> 
>> I could add something to A8 that says “Detailed questions can be
>> directed to linux-nfs@vger.kernel.org.” Do you feel you got a good
>> answer from the mailing list?
>> 
>> --
>> Chuck Lever
>> chuck[dot]lever[at]oracle[dot]com
>> 
>> 

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



