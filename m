From: Guillaume Rousse <Guillaume.Rousse-MZpvjPyXg2s@public.gmane.org>
Subject: Re: trouble using kerberos between linux client and server
Date: Thu, 13 May 2010 11:09:04 +0200
Message-ID: <4BEBC1B0.8030502@inria.fr>
References: <4BCFE979.2000406@inria.fr> <4BE1E099.9050902@inria.fr>	 <4BEB1FA2.1060001@inria.fr> <AANLkTinNTYrEe9G6urXBxv-hogZPatOe9zWbbjnVTbWz@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Kevin Coffman <kwc@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail4-relais-sop.national.inria.fr ([192.134.164.105]:17395
	"EHLO mail4-relais-sop.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752915Ab0EMJJH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 May 2010 05:09:07 -0400
In-Reply-To: <AANLkTinNTYrEe9G6urXBxv-hogZPatOe9zWbbjnVTbWz-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Le 13/05/2010 01:21, Kevin Coffman a =E9crit :
> On Wed, May 12, 2010 at 5:37 PM, Guillaume Rousse
> <Guillaume.Rousse-MZpvjPyXg2s@public.gmane.org> wrote:
>> Le 05/05/2010 23:18, Guillaume Rousse a =E9crit :
>>> I'm attaching network capture, even I can't figure additional
>>> information from it by myself.
>> Reading https://bugzilla.redhat.com/show_bug.cgi?id=3D562807, I rebu=
ild
>> libtirpc with patch applied and -DDEBUG. Unfortunatly, it doesn't br=
ing
>> additional information about the server-side failure :(
>=20
> It looks to me like fflush(), called in qword_eol(), may be returning
> the number of bytes flushed (95) rather than zero for success?  I
> don't immediately see any changes that would cause this.  But I
> haven't looked extensively...
Not necessarily a change: I never used a kerberized server sofar, only
clients.
--=20
BOFH excuse #164:

root rot
