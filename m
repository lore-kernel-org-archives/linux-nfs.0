Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:33609 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753979Ab0EMMzw convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 May 2010 08:55:52 -0400
Received: by gyg13 with SMTP id 13so528439gyg.19
        for <linux-nfs@vger.kernel.org>; Thu, 13 May 2010 05:55:51 -0700 (PDT)
In-Reply-To: <4BEBC1B0.8030502@inria.fr>
References: <4BCFE979.2000406@inria.fr> <4BE1E099.9050902@inria.fr>
	 <4BEB1FA2.1060001@inria.fr>
	 <AANLkTinNTYrEe9G6urXBxv-hogZPatOe9zWbbjnVTbWz@mail.gmail.com>
	 <4BEBC1B0.8030502@inria.fr>
Date: Thu, 13 May 2010 08:55:50 -0400
Message-ID: <AANLkTinPfbYgqFxcIuT3975TAtk0e1D84bMAeez5Z06T@mail.gmail.com>
Subject: Re: trouble using kerberos between linux client and server
From: Kevin Coffman <kwc@citi.umich.edu>
To: Guillaume Rousse <Guillaume.Rousse@inria.fr>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, May 13, 2010 at 5:09 AM, Guillaume Rousse
<Guillaume.Rousse@inria.fr> wrote:
> Le 13/05/2010 01:21, Kevin Coffman a écrit :
>> On Wed, May 12, 2010 at 5:37 PM, Guillaume Rousse
>> <Guillaume.Rousse@inria.fr> wrote:
>>> Le 05/05/2010 23:18, Guillaume Rousse a écrit :
>>>> I'm attaching network capture, even I can't figure additional
>>>> information from it by myself.
>>> Reading https://bugzilla.redhat.com/show_bug.cgi?id=562807, I rebuild
>>> libtirpc with patch applied and -DDEBUG. Unfortunatly, it doesn't bring
>>> additional information about the server-side failure :(
>>
>> It looks to me like fflush(), called in qword_eol(), may be returning
>> the number of bytes flushed (95) rather than zero for success?  I
>> don't immediately see any changes that would cause this.  But I
>> haven't looked extensively...
> Not necessarily a change: I never used a kerberized server sofar, only
> clients.

Well, I've not seen that issue before, so I assumed it was a change.
I looked back a bit, but didn't see: what versions of nfs-utils and
kernel are on the server?
