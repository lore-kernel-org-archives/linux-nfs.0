From: Jason Holmes <jholmes@psu.edu>
Subject: Re: NFS stops responding
Date: Wed, 13 Oct 2004 11:07:07 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <416D449B.7060908@psu.edu>
References: <1096551562.2696.19.camel@douglas-furlong.firebox.com>	 <415C2F07.4030308@psu.edu> <415C5A33.50202@psu.edu>	 <415D7A76.7000404@psu.edu> <1097146611.4160.24.camel@douglas-furlong.firebox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CHkju-0000IC-AC
	for nfs@lists.sourceforge.net; Wed, 13 Oct 2004 08:08:30 -0700
Received: from vpn-19-13.aset.psu.edu ([146.186.19.13] helo=funkmachine.cac.psu.edu)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CHkiM-0005wI-DL
	for nfs@lists.sourceforge.net; Wed, 13 Oct 2004 08:08:30 -0700
To: Douglas Furlong <douglas.furlong@firebox.com>
In-Reply-To: <1097146611.4160.24.camel@douglas-furlong.firebox.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Douglas Furlong wrote:
> On Fri, 2004-10-01 at 11:40 -0400, Jason Holmes wrote:
> 
>>FYI, I'm beginning to suspect that this is a problem more with the newer 
>>RedHat kernels than anything else.  I've only had one vanilla kernel NFS 
>>lockup since I moved the NFS servers to 2.6.8.1 (3 days) and that 
>>happened right after I did the move, so it could be coincidental.  Back 
>>when the servers ran RedHat kernels, the RedHat kernel clients never 
>>locked up whereas the vanilla clients did.  Yesterday I had 4 NFS 
>>lockups on the same machine running the RedHat 2.4.21-20.ELsmp kernel 
>>(the one that generated the trace below), but it hasn't locked up since 
>>I moved it to 2.6.8.1.  I guess I'll know for sure if my lockups don't 
>>come back for a week or so.
>>
>>Thanks,
> 
> <snip>
> 
> Have you had any more lockups?
> 
> Would you feel happy entering a bugzilla entry for this problem over at
> redhat? You seem to have got a lot more information then I have in my
> trouble shooting, I will then add what ever else I have, and my local
> setup.

I'm sorry to say that I had my first lockup this morning after a week 
and a half of no problems.  I was unfortunately unable to get any 
debugging information from it at the time.  This was a 2.4.27 client 
against a 2.6.8.1 server.

Thanks,

--
Jason Holmes


-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
