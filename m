From: Jehan PROCACCIA <Jehan.Procaccia@int-evry.fr>
Subject: Re: interprtation of /proc/net/rpc/nfsd
Date: Fri, 08 Oct 2004 17:46:15 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <4166B647.2010506@int-evry.fr>
References: <41666777.7030003@int-evry.fr> <4166900D.3060401@moving-picture.com> <416695F6.8080707@int-evry.fr> <4166A7A3.4020705@moving-picture.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CFwwv-0003eK-LZ
	for nfs@lists.sourceforge.net; Fri, 08 Oct 2004 08:46:29 -0700
Received: from smtp2.int-evry.fr ([157.159.10.45])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CFwwu-000268-Ly
	for nfs@lists.sourceforge.net; Fri, 08 Oct 2004 08:46:29 -0700
To: James Pearson <james-p@moving-picture.com>
In-Reply-To: <4166A7A3.4020705@moving-picture.com>
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

James Pearson wrote:

>>
>> $ grep th /proc/net/rpc/nfsd
>> th 8 41598 20357.020 3974.540 1809.300 0.000 998.210 781.650 483.840 
>> 116.640 0.000 825.230
>>
>> Why ten numbers, I have 8 thraeds ! ? here for the last number for 
>> exemple, I had 825seconds that thread number 8 was at 230% of it's 
>> maximum ???
>
>
> The following post from Neil Brown has a 'better' explanation:
>
> http://marc.theaimsgroup.com/?l=linux-nfs&m=102824853219024&w=2
>
> James Pearson

Very well, It is clear to me now :-) !
however how can I zero these counters ?, restarting /etc/init.d/nfs 
doesn't do it, neither :
$ nfsstat -z
nfsstat: zeroing of nfs server statistics is not supported
nfsstat: zeroing of nfs client statistics is not supported

Is the only solution is to rebbot :-( ?


-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
