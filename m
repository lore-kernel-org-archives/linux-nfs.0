From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFSD IPv6 support for 2.6.29
Date: Tue, 9 Dec 2008 16:04:07 -0500
Message-ID: <20081209210407.GE8596@fieldses.org>
References: <9BBD5BD5-C461-43C4-AEB0-69D3E31F92B7@oracle.com> <4917C380.9040703@linux.vnet.ibm.com> <C44F9C62-2770-4879-8AC7-B1C8D81F9AB6@oracle.com> <491AFE09.2010803@bull.net> <2BF8FCDB-0C6D-430E-B2AE-4C293E30A1AE@oracle.com> <4921AF45.4070009@bull.net> <AF604C91-2F1B-48A3-8E1D-84D5CBBB2856@oracle.com> <493E6680.2050904@bull.net> <9F0B9CDF-DDA7-4752-B08D-EC43A3D664E1@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Le Rouzic <aime.le-rouzic@bull.net>,
	Varun Chandramohan <varunc@linux.vnet.ibm.com>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	Frank S Filz <ffilz@us.ibm.com>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:45060 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752652AbYLIVEP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Dec 2008 16:04:15 -0500
In-Reply-To: <9F0B9CDF-DDA7-4752-B08D-EC43A3D664E1@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 09, 2008 at 11:24:46AM -0500, Chuck Lever wrote:
> On Dec 9, 2008, at Dec 9, 2008, 7:37 AM, Le Rouzic wrote:
>> Chuck Lever a =C3=A9crit :
>>
>>>>>>>>> Bruce asked me to collect server-side IPv6 patches for =20
>>>>>>>>> upstream.
>>>>>>>>> I've collected the patches that have been posted on the=20
>>>>>>>>> list, and
>>>>>>>>> added some fixes of my own.
>>>>>>>>>
>>>>>>>>> Can you have a look at
>>>>>>>>>
>>>>>>>>> http://git.linux-nfs.org/?p=3Dcel/cel-2.6.git;a=3Dsummary
>>>>>>>>>
>>>>>>>>> tag cel-ipv6-10292008
>>>>>>>>>
>>>>>>>>> These have been build tested, but I haven't done any run-time
>>>>>>>>> testing yet.
>>>>>>>>>
>>>>>>>>> --
>>>>>>>>> Chuck Lever
>>>>>>>>> chuck[dot]lever[at]oracle[dot]com
>>>>>>>>
>>>> Hi
>>>> I have tested the "tag cel-ipv6-10292008" and some robustness test=
s
>>>> started simultaneously (connectathon, fsx, iozone, fss_stress, ffs=
b)
>>>> have
>>>> been running fine during several hours in IPV6 and IPV4.
>>>> I used the my nfs-utils package based on nfs-utils.1.1.2
>>>> (http://nfsv4.bullopensource.org/)
>>>
>>   Hi,
>>   I get an issue with AIX used as client in front of the above
>> snapshot used on a linux server.
>>
>>    Doing the following on the AIX side:
>>
>>      mount -o vers=3D4 nfs4gb:/ /mnt/nosec
>>      cd /mnt/nosec
>>      mkdir rep
>>      cd rep
>>
>>      the command "ls" will fail with the follwing error on the AIX =20
>> side:
>>    "kern:err|error unix: Client encounters unexpected
>> NFS4ERR_BAD_COOKIE error from server"
>>
>>     The problem happens with IPV6 and IPV4
>
> This is probably an issue with NFSv4 proper.  Bruce?

Somebody needs to look at a network trace of the above commands, and
find the request that got the BAD_COOKIE return.  It should be to a
readdir request.  Check whether the cookie the client provides in that
request was in fact returned from a previous readdir--if so, this is
probably a server bug, if not, probably a client bug.

Also note there's known problems between an AIX client an linux NFSv4
server when the exported filesystem is ext2 or ext3; xfs, for example,
should work.  (The problem is inadequate ctime resolution on ext2 and
ext3).

--b.
