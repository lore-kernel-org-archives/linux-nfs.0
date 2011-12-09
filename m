Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mexforward.lss.emc.com ([128.222.32.20]:28491 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751855Ab1LIDJE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Dec 2011 22:09:04 -0500
Date: Thu, 08 Dec 2011 22:11:42 -0500
To: "Rick Macklem" <rmacklem@uoguelph.ca>
Subject: Re: Slides from the pNFS BoF we delivered at LISA 11 - with
 attachment this time
From: "Sorin Faibish" <sfaibish@emc.com>
Cc: honey@citi.umich.edu, linux-nfs@vger.kernel.org, nfsv4@ietf.org
Content-Type: text/plain; format=flowed; delsp=yes; charset=iso-8859-15
MIME-Version: 1.0
References: <813790898.1157715.1323399200260.JavaMail.root@erie.cs.uoguelph.ca>
Message-ID: <op.v57chsbmrwwil4@sfaibish1.corp.emc.com>
In-Reply-To: <813790898.1157715.1323399200260.JavaMail.root@erie.cs.uoguelph.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 08 Dec 2011 21:53:20 -0500, Rick Macklem <rmacklem@uoguelph.ca>  
wrote:

> Thanks for the slides, Sorin.
>
> Just fyi, it was correct to not mention a FreeBSD client, since the
> 4.1 client code hasn't made it into any release yet. It is available
> as a patch against the FreeBSD9.0 kernel, in case anyone is interested:
>    http://people.freebsd.org/~rmacklem/nfsv4.1-client/nfsv41.patch
>
> I am just starting to work on the logistics of getting this into the
> FreeBSD source tree, so it may be in a FreeBSD9.n release, where n > 0.
>
> Also, the above does not include any pNFS support. I am about ready to
> start coding pNFS client stuff, which brings me to...
> - It will be difficult for me to make much progress without any
>   pNFS servers to test against. (The only NFSv4.1 server I have to
>   test against is Fedora15 and I don't think it knows how to do pNFS?
>   If there is a way to make Fedora15/16 (or any other freebie Linux
>   distro) do pNFS, please let me know.
One suggestion is to try to use the pNFS for Lustre. I can send you the
patches or you can get them from Lustre tree. Let me know if this will be
good for you. We are already using it to test Linux file client as well as
Windows. Whamcloud demo it during SC11 and demo wire speed.

What I would also suggest is for you maybe to come to the Connectathon in
February and test the client against the other servers that you cannot have
as they are not products but prototypes.

>
> If others have suggestions on how I might gain access to pNFS servers
> for testing, I would appreciate hearing. (However, I am not funded to
> do any of this, so the suggestions can't include my spending $$$. I can
> make it to a Bakeathon when it happens to be close to where I am, so I
> can show up "on the cheap", like I did last June in Ann Arbor.)
Sure. The next BAT is at CITI so maybe you bring a client prototype
there.

/Sorin

>
> rick
>
> ----- Original Message -----
>> On Thu, 08 Dec 2011 19:40:19 -0500, Sorin Faibish <sfaibish@emc.com>
>> wrote:
>>
>> > Attached please find the slides that we presented yesterday at
>> > USENIX
>> > LISA 11
>> > conference in Boston. We would like to get more detailed input on
>> > other
>> > OS
>> > that will support pNFS server/client (this is for Rick as well) that
>> > were
>> > not mentioned in this slide set.
>> >
>> > /Sorin
>> >
>>
>>
>>
>> --
>> Best Regards
>> Sorin Faibish
>> Corporate Distinguished Engineer
>> Unified Storage Division
>>
>> EMC²
>> where information lives
>>
>> Phone: 508-435-1000 x 48545
>> Cellphone: 617-510-0422
>> Email : sfaibish@emc.com
>
>



-- 
Best Regards
Sorin Faibish
Corporate Distinguished Engineer
Unified Storage Division

        EMC²
where information lives

Phone: 508-435-1000 x 48545
Cellphone: 617-510-0422
Email : sfaibish@emc.com
