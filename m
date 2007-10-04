From: Peter Staubach <staubach@redhat.com>
Subject: Re: What's slated for inclusion in 2.6.24-rc1 from the NFS
 client git tree...
Date: Thu, 04 Oct 2007 15:41:57 -0400
Message-ID: <47054205.8000908@redhat.com>
References: <1191454876.6726.32.camel@heimdal.trondhjem.org>	
	<20071004085206.0a8e37b5@poseidon.drzeus.cx>	
	<1191506450.6685.17.camel@heimdal.trondhjem.org>	
	<20071004184304.6e71ab6d@poseidon.drzeus.cx>	
	<20071004114243.3161af16.akpm@linux-foundation.org>
	<1191525363.6739.12.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Andrew Morton <akpm@linux-foundation.org>, nfsv4@linux-nfs.org,
	linux-kernel@vger.kernel.org, Pierre Ossman <drzeus-list@drzeus.cx>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IdWag-0004tw-9g
	for nfs@lists.sourceforge.net; Thu, 04 Oct 2007 12:42:34 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IdWak-0004Jg-6s
	for nfs@lists.sourceforge.net; Thu, 04 Oct 2007 12:42:39 -0700
In-Reply-To: <1191525363.6739.12.camel@heimdal.trondhjem.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Trond Myklebust wrote:
> On Thu, 2007-10-04 at 11:42 -0700, Andrew Morton wrote:
>   
>> On Thu, 4 Oct 2007 18:43:04 +0200
>> Pierre Ossman <drzeus-list@drzeus.cx> wrote:
>>
>>     
>>> On Thu, 04 Oct 2007 10:00:50 -0400
>>> Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
>>>
>>>       
>>>> On Thu, 2007-10-04 at 08:52 +0200, Pierre Ossman wrote:
>>>>         
>>>>> On Wed, 03 Oct 2007 19:41:16 -0400
>>>>> Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
>>>>>
>>>>>           
>>>>>> We also have the 64-bit inode support from RedHat/Peter Staubach.
>>>>>>
>>>>>>             
>>>>> As has been pointed[1] out[2], this will cause regressions for
>>>>> non-LFS applications (of which there are still lots and lots). This
>>>>> change should be in feature-removal (the "feature" being removed is
>>>>> legacy support for non-LFS applications using NFS servers that make
>>>>> full use of the protocol) and preferably accompanied with
>>>>> appropriate user space changes (e.g. compatibility option in glibc).
>>>>>
>>>>> [1] https://bugzilla.redhat.com/show_bug.cgi?id=241348
>>>>> [2] http://marc.info/?l=linux-nfs&m=118701088726477&w=2
>>>>>
>>>>> Rgds
>>>>>           
>>>> How about a boot/module parameter to turn it on or off?
>>>>
>>>>         
>>> That would be perfect. It can even be in non-legacy mode by default,
>>> just as long as you can go back to the old behaviour when/if you run
>>> into a non-LFS application.
>>>
>>>       
>> Wouldn't a mount option be better?
>>     
>
> I suppose that might be OK if you know that the 32-bit legacy
> applications will only touch one or two servers, but that sounds like a
> niche thing.
>
> On the downside, forcing all those people who have portable 64-bit aware
> applications to upgrade their version of mount just in order to have
> stat64() work correctly seems unnecessarily complicated. I'd prefer not
> to have to do that unless someone comes up with a good reason why we
> must.

I would agree.  The 64 bit fileids will only become visible when
the server is exporting file systems which contain fileids which
are bigger than 32 bits and then only when the application
encounters these files.

Also, these 32-bit legacy applications are going to have a
problem if they are ever run on a system which contains local
file systems which expose the large fileids.

It would be better to identify these applications and get them
fixed.  The world is evolving and it is time for them to do so.

       ps

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
