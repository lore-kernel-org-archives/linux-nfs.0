From: Dean Hildebrand <seattleplus@gmail.com>
Subject: Re: [PATCH 0/1] SUNRPC: Add sysctl variables for server TCP snd/rcv
 buffer values
Date: Wed, 18 Jun 2008 11:33:06 -0700
Message-ID: <485954E2.2070906@gmail.com>
References: <484ECDE4.6030108@gmail.com> <7F44A14A-F811-4D41-BAFF-E019E9904B6A@oracle.com> <48518F18.2010703@gmail.com> <20080613205339.GM8501@fieldses.org> <4853098C.8070200@gmail.com> <20080616175946.GB27083@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.174]:32646 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753400AbYFRSdK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Jun 2008 14:33:10 -0400
Received: by wf-out-1314.google.com with SMTP id 27so373405wfd.4
        for <linux-nfs@vger.kernel.org>; Wed, 18 Jun 2008 11:33:09 -0700 (PDT)
In-Reply-To: <20080616175946.GB27083@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



J. Bruce Fields wrote:
> On Fri, Jun 13, 2008 at 04:58:04PM -0700, Dean Hildebrand wrote:
>   
>> The reason it is an art is that you don't know the hardware that exists  
>> between the client and server.  Talking about things like BDP is fine,  
>> but in reality there are limited buffer sizes, flaky hardware,  
>> fluctuations in traffic, etc etc.  Using the BDP as a starting point  
>> though seems like the best solution, but since the linux server doesn't  
>> know anything about what the BDP is, it is tough to hard code any value  
>> into the linux kernel.  As you said, if we just give a reasonable  
>> default value and then ensure people can play with the knobs.  Most  
>> people use NFS within a LAN, and to date there has been little if any  
>> discussion on using NFS over the WAN (hence my interest), so I would  
>> argue that the current values might not be all that bad with regards to  
>> defaults (at least we know the behaviour isn't horrible for most people).
>>
>> Networks are messy.  Anyone who wants to work in the WAN is going to  
>> have to read about such things, no way around it.  A simple google  
>> search for 'tcp wan' or 'tcp wan linux' gives loads of suggestions on  
>> how to configure your network, so it really isn't a burden on sysadmins  
>> to do such a search and then use the given knobs to adjust the tcp  
>> buffer size appropriately.  My patch gives sysadmins the ability to do  
>> the google search and then have some knobs to turn.
>>
>> Some sample tcp tuning guides that I like:
>> http://acs.lbl.gov/TCP-tuning/tcp-wan-perf.pdf
>> http://acs.lbl.gov/TCP-tuning/linux.html
>> http://gentoo-wiki.com/HOWTO_TCP_Tuning (especially relevant is the part  
>> about the receive buffer)
>>     
>  
>   
>> http://www.linuxclustersinstitute.org/conferences/archive/2008/PDF/Hildebrand_98265.pdf 
>> (our initial paper on pNFS tuning)
>>     
>
> Several of those refer to problems that can happen when the receive
> buffer size is set unusually high, but none of them give a really
> detailed description of the behavior in that case--do you know of any?
>   
In an earlier post, I referred to the saw-tooth pattern that will happen 
with the window when the sender transmits faster than the receiver can 
receive.  I believe bic and cubic try to reduce the impact by not 
closing the window all the way, but it is still better to not 
intentionally lose packets by setting the receive buffer too high.  Not 
sure if I sent this doc out already, but it also has some info on tuned 
buffers vs. parallel tcp streams.  It also shows some graphs of the 
window closing once too many packets are lost.
http://acs.lbl.gov/TCP-tuning/TCP-Tuning-Tutorial.pdf

Sections 2.1 and 2.2 of the following paper published SC2002 give an 
interesting intro to tuning tcp buffers and the ups and downs of using 
parallel TCP streams.  They quote the gridftp papers and indicate that 
the best performance is with parallel tcp streams and tuned buffers.  
They give the danger of setting a buffer size too big as:
"Although memory is comparably cheap, the vast majority of the 
connections are so small that allocating large buffers to each flow can 
put any system at risk
of running out of memory."
http://www.supercomp.org/sc2002/paperpdfs/pap.pap151.pdf

(Note, both of the following docs are from the same person.  There are 
other docs, they are don't seem to be quite as clear.)
Dean

