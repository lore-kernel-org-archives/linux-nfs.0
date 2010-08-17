Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:52723 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753492Ab0HQR42 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Aug 2010 13:56:28 -0400
Received: by wyb32 with SMTP id 32so7300666wyb.19
        for <linux-nfs@vger.kernel.org>; Tue, 17 Aug 2010 10:56:26 -0700 (PDT)
In-Reply-To: <4C66B207.5060101@inria.fr>
References: <4BCFE979.2000406@inria.fr>
	<4BE1E099.9050902@inria.fr>
	<4BEB1FA2.1060001@inria.fr>
	<AANLkTinNTYrEe9G6urXBxv-hogZPatOe9zWbbjnVTbWz@mail.gmail.com>
	<4BEBC1B0.8030502@inria.fr>
	<AANLkTinPfbYgqFxcIuT3975TAtk0e1D84bMAeez5Z06T@mail.gmail.com>
	<4BEC6B6E.9090705@inria.fr>
	<4C66B207.5060101@inria.fr>
Date: Tue, 17 Aug 2010 13:56:26 -0400
Message-ID: <AANLkTim2LL+utWDeEUWrgyrSuNiQv0HeUTPLn7oPNKK2@mail.gmail.com>
Subject: Re: trouble using kerberos between linux client and server
From: Kevin Coffman <kwc@citi.umich.edu>
To: Guillaume Rousse <Guillaume.Rousse@inria.fr>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, Aug 14, 2010 at 11:11 AM, Guillaume Rousse
<Guillaume.Rousse@inria.fr> wrote:
> Le 13/05/2010 23:13, Guillaume Rousse a écrit :
>> Le 13/05/2010 14:55, Kevin Coffman a écrit :
>>> On Thu, May 13, 2010 at 5:09 AM, Guillaume Rousse
>>> <Guillaume.Rousse@inria.fr> wrote:
>>>> Le 13/05/2010 01:21, Kevin Coffman a écrit :
>>>>> On Wed, May 12, 2010 at 5:37 PM, Guillaume Rousse
>>>>> <Guillaume.Rousse@inria.fr> wrote:
>>>>>> Le 05/05/2010 23:18, Guillaume Rousse a écrit :
>>>>>>> I'm attaching network capture, even I can't figure additional
>>>>>>> information from it by myself.
>>>>>> Reading https://bugzilla.redhat.com/show_bug.cgi?id=562807, I rebuild
>>>>>> libtirpc with patch applied and -DDEBUG. Unfortunatly, it doesn't bring
>>>>>> additional information about the server-side failure :(
>>>>>
>>>>> It looks to me like fflush(), called in qword_eol(), may be returning
>>>>> the number of bytes flushed (95) rather than zero for success?  I
>>>>> don't immediately see any changes that would cause this.  But I
>>>>> haven't looked extensively...
>>>> Not necessarily a change: I never used a kerberized server sofar, only
>>>> clients.
>>>
>>> Well, I've not seen that issue before, so I assumed it was a change.
>>> I looked back a bit, but didn't see: what versions of nfs-utils and
>>> kernel are on the server?
>> The same on both sides: kernel 2.6.33.3 + nfs-utils 1.2.2
> Hello.
>
> I finally managed to understand the issue: I also need rpc.svcgssd _and_
> rpc.gssd on server side, whereas I thought rpc.gssd was needed on client
> side only
> (http://wiki.linux-nfs.org/wiki/index.php/Enduser_doc_kerberos). Is this
> expected behaviour ?

Wow, I'm glad you finally found it.

rpc.svcgssd is always required on the server if you are using
Kerberos.  rpc.gssd is required on the server if you want delegations
to work when using Kerberos (requires authenticated callback from the
server to the client).  It was my understanding that no ill effects
should be seen if you do not run rpc.gssd on the server, you just
wouldn't be able to give out delegations.  However, I may be
mis-remembering something.

K.C.
