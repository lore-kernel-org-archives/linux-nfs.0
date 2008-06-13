From: Dean Hildebrand <seattleplus@gmail.com>
Subject: Re: [PATCH 0/1] SUNRPC: Add sysctl variables for server TCP snd/rcv
 buffer values
Date: Fri, 13 Jun 2008 16:58:04 -0700
Message-ID: <4853098C.8070200@gmail.com>
References: <484ECDE4.6030108@gmail.com> <7F44A14A-F811-4D41-BAFF-E019E9904B6A@oracle.com> <48518F18.2010703@gmail.com> <20080613205339.GM8501@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.169]:13395 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756155AbYFMX6K (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Jun 2008 19:58:10 -0400
Received: by wf-out-1314.google.com with SMTP id 27so4338170wfd.4
        for <linux-nfs@vger.kernel.org>; Fri, 13 Jun 2008 16:58:09 -0700 (PDT)
In-Reply-To: <20080613205339.GM8501@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



J. Bruce Fields wrote:
> On Thu, Jun 12, 2008 at 02:03:20PM -0700, Dean Hildebrand wrote:
>   
>> Another point is that setting the buffer size isn't always a  
>> straightforward process.  All papers I've read on the subject, and my  
>> experience confirms this, is that setting tcp buffer sizes is more of an  
>> art.
>>     
>
> Aie.  It's bad enough if we have a half-dozen or so sysctl's to set to
> get decent performance out of the nfs server.  I don't like to hear
> that, on top of that, the choice of at least one of those variables is
> an art....
>
> We can leave some knobs in there for the people that like to read that
> sort of paper, but the rest of the world will need *some* sort of
> heuristics.
>   
Yeah, who thought computers could be artistic?!  More fun that way I 
figure :)

The reason it is an art is that you don't know the hardware that exists 
between the client and server.  Talking about things like BDP is fine, 
but in reality there are limited buffer sizes, flaky hardware, 
fluctuations in traffic, etc etc.  Using the BDP as a starting point 
though seems like the best solution, but since the linux server doesn't 
know anything about what the BDP is, it is tough to hard code any value 
into the linux kernel.  As you said, if we just give a reasonable 
default value and then ensure people can play with the knobs.  Most 
people use NFS within a LAN, and to date there has been little if any 
discussion on using NFS over the WAN (hence my interest), so I would 
argue that the current values might not be all that bad with regards to 
defaults (at least we know the behaviour isn't horrible for most people).

Networks are messy.  Anyone who wants to work in the WAN is going to 
have to read about such things, no way around it.  A simple google 
search for 'tcp wan' or 'tcp wan linux' gives loads of suggestions on 
how to configure your network, so it really isn't a burden on sysadmins 
to do such a search and then use the given knobs to adjust the tcp 
buffer size appropriately.  My patch gives sysadmins the ability to do 
the google search and then have some knobs to turn.

Some sample tcp tuning guides that I like:
http://acs.lbl.gov/TCP-tuning/tcp-wan-perf.pdf
http://acs.lbl.gov/TCP-tuning/linux.html
http://gentoo-wiki.com/HOWTO_TCP_Tuning (especially relevant is the part 
about the receive buffer)
http://www.linuxclustersinstitute.org/conferences/archive/2008/PDF/Hildebrand_98265.pdf 
(our initial paper on pNFS tuning)

Dean

