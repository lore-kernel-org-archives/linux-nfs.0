From: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Subject: Re: [PATCH 4/5] NFSD: Remove NFSD_TCP kernel build option
Date: Wed, 06 Feb 2008 10:05:39 +1100
Message-ID: <47A8EBC3.7050900@melbourne.sgi.com>
References: <20080205000442.18602.29035.stgit@manray.1015granger.net> <47A7AB89.7020709@melbourne.sgi.com> <1202170754.28484.57.camel@heimdal.trondhjem.org> <47A7AE03.10401@melbourne.sgi.com> <4BE5A1AE-DB3B-4796-B6BD-5691930258C8@oracle.com> <47A7F8F3.3020907@melbourne.sgi.com> <20080205155021.GA7805@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Chuck Lever <chuck.lever@oracle.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	bfields@citi.umich.edu, linux-nfs@vger.kernel.org
To: Frank van Maarseveen <frankvm@frankvm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.171.29]:36090 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754913AbYBEW7I (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Feb 2008 17:59:08 -0500
In-Reply-To: <20080205155021.GA7805@janus>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Frank van Maarseveen wrote:
> On Tue, Feb 05, 2008 at 04:49:39PM +1100, Greg Banks wrote:
>   
>> Chuck Lever wrote:
>>     
>>> On Feb 4, 2008, at 7:29 PM, Greg Banks wrote:
>>>       
>>>> Trond Myklebust wrote:
>>>>         
>>>>> On Tue, 2008-02-05 at 11:19 +1100, Greg Banks wrote:
>>>>>
>>>>>           
>>>>>> Chuck Lever wrote:
>>>>>>
>>>>>>             
>>>>>>> TCP support in the Linux NFS server is stable enough that we can
>>>>>>> leave it
>>>>>>> on always.  CONFIG_NFSD_TCP adds about 10 lines of code, and
>>>>>>> defaults to
>>>>>>> "Y" anyway.
>>>>>>>
>>>>>>> A run-time switch might be more appropriate if people feel they
>>>>>>> would like
>>>>>>> to disable NFSD's TCP support.
>>>>>>>
>>>>>>>
>>>>>>>
>>>>>>>               
>>>>>> Looks good.
>>>>>>
>>>>>> Actually, I'd be inclined to go one step further and set UDP support
>>>>>> off by default.
>>>>>>
>>>>>>             
>>>>> That will break older clients.
>>>>>
>>>>>
>>>>>           
>>>> Hence the default, rather than removing the code entirely.
>>>>         
>>> What might make sense is to remove NFSD_TCP, but add NFSD_UDP,
>>> defaulting to Y.
>>>
>>> Then in a year or two we can change the default to N.
>>>
>>>       
>> Fine by me.
>>     
>
> Last time I checked (around 2.6.22) writing large files on NFSv3 over
> UDP was 20% faster compared to TCP (Gb LAN with one switch connecting
> all machines).
>   
Did all of your file arrive at the server, and in the same order it left
the client?  NFS on UDP relies on IP fragmentation, which is known to
introduce silent data corruption at high data rates (google for "IPID aliasing").

Also, last time I checked, UDP support in the server uses a single socket
for all traffic, and processes need to serialise on the svc_sock lock to send,
so aggregate UDP throughput is strictly limited compared to TCP.  As in, 145 MB/s
for UDP compared to filling 12 1gige pipes for TCP.  I have a patch to fix this,
but given the inherent data corruption issues of UDP I haven't bothered posting
the most recent version.



> TCP and its timeout/retransmission behavior isn't always the best choice.
>
>   
The timeout & retrans that sunrpc implements on top of UDP is arguably worse,
especially if you use the "soft" mount option.

-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
The cake is *not* a lie.
I don't speak for SGI.

