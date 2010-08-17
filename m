Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:55214 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754480Ab0HQRr0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Aug 2010 13:47:26 -0400
Date: Tue, 17 Aug 2010 13:45:24 -0400
To: Guillaume Rousse <Guillaume.Rousse@inria.fr>
Cc: Kevin Coffman <kwc@citi.umich.edu>, linux-nfs@vger.kernel.org
Subject: Re: trouble using kerberos between linux client and server
Message-ID: <20100817174523.GB23176@fieldses.org>
References: <4BCFE979.2000406@inria.fr>
 <4BE1E099.9050902@inria.fr>
 <4BEB1FA2.1060001@inria.fr>
 <AANLkTinNTYrEe9G6urXBxv-hogZPatOe9zWbbjnVTbWz@mail.gmail.com>
 <4BEBC1B0.8030502@inria.fr>
 <AANLkTinPfbYgqFxcIuT3975TAtk0e1D84bMAeez5Z06T@mail.gmail.com>
 <4BEC6B6E.9090705@inria.fr>
 <4C66B207.5060101@inria.fr>
Content-Type: text/plain; charset=utf-8
In-Reply-To: <4C66B207.5060101@inria.fr>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, Aug 14, 2010 at 05:11:03PM +0200, Guillaume Rousse wrote:
> Le 13/05/2010 23:13, Guillaume Rousse a écrit :
> > Le 13/05/2010 14:55, Kevin Coffman a écrit :
> >> On Thu, May 13, 2010 at 5:09 AM, Guillaume Rousse
> >> <Guillaume.Rousse@inria.fr> wrote:
> >>> Le 13/05/2010 01:21, Kevin Coffman a écrit :
> >>>> On Wed, May 12, 2010 at 5:37 PM, Guillaume Rousse
> >>>> <Guillaume.Rousse@inria.fr> wrote:
> >>>>> Le 05/05/2010 23:18, Guillaume Rousse a écrit :
> >>>>>> I'm attaching network capture, even I can't figure additional
> >>>>>> information from it by myself.
> >>>>> Reading https://bugzilla.redhat.com/show_bug.cgi?id=562807, I rebuild
> >>>>> libtirpc with patch applied and -DDEBUG. Unfortunatly, it doesn't bring
> >>>>> additional information about the server-side failure :(
> >>>>
> >>>> It looks to me like fflush(), called in qword_eol(), may be returning
> >>>> the number of bytes flushed (95) rather than zero for success?  I
> >>>> don't immediately see any changes that would cause this.  But I
> >>>> haven't looked extensively...
> >>> Not necessarily a change: I never used a kerberized server sofar, only
> >>> clients.
> >>
> >> Well, I've not seen that issue before, so I assumed it was a change.
> >> I looked back a bit, but didn't see: what versions of nfs-utils and
> >> kernel are on the server?
> > The same on both sides: kernel 2.6.33.3 + nfs-utils 1.2.2
> Hello.
> 
> I finally managed to understand the issue: I also need rpc.svcgssd _and_
> rpc.gssd on server side, whereas I thought rpc.gssd was needed on client
> side only
> (http://wiki.linux-nfs.org/wiki/index.php/Enduser_doc_kerberos). Is this
> expected behaviour ?

If you want krb5 callbacks to work (for example, if you want delegations
to be granted when using krb5 with NFSv4.0), then rpc.gssd needs to be
run on the server.

If rpc.gssd isn't running on the server, then I'd expect the only
symptom to be that delegations aren't given out; if you're seeing a more
serious failure than that, then that's a bug.

--b.
