From: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
Subject: Re: client apps not surviving nfsd restart
Date: Fri, 20 Aug 2004 15:55:47 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <412602E3.5040000@bio.ifi.lmu.de>
References: <4125EA9F.3040304@bio.ifi.lmu.de> <20040820130246.GB12371@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1By9rz-0005IB-9c
	for nfs@lists.sourceforge.net; Fri, 20 Aug 2004 06:55:51 -0700
Received: from acheron.informatik.uni-muenchen.de ([129.187.214.135])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1By9ry-0000hI-Hm
	for nfs@lists.sourceforge.net; Fri, 20 Aug 2004 06:55:51 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20040820130246.GB12371@suse.de>
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

Olaf Kirch wrote:
> On Fri, Aug 20, 2004 at 02:12:15PM +0200, Frank Steiner wrote:
> 
>>   In the NFS howto I read that the disadvantage of nfs-over-tcp is that
>>   "If your server crashes in the middle of a packet transmission, the
>>    client will hang and any shares will need to be unmounted and 
>>    remounted."
> 
> 
> I have never observed this behavior. TCP reconnect works just fine.

Hmm, ok. So the stales we saw might have been cause by some other
difference between SuSE 7.3 and 9.0. Could the lock manager be a
cause for this? With SuSE 7.3 we had everything mounted with "nolock".
Now with SusE 9.0 we use locks. Could that cause stales like we
experienced on /usr?

> 
> 
>>2) We are currently testing kernel 2.6.8.1. The nfs behaviour seems
>>   to have changed in some ways. Running e.g. "find /" on a diskless
>>   client with kernel 2.4 would just hang when the server rebootet
>>   and later go on when the server was back.
> 
> 
> What does your exports table look like? Do you have network exports
> or other kinds of wildcarding? I have a report of nfsd/mountd not
> properly reloading the kernel's export table after a nfsd restart.

We are using netgroups. For testing I removed them and just left
entries for one diskless client, without any wildcards or group
but it does not make a difference (I rebooted client and server
with the new exports just to make sure...)

> 
> 
>>   With 2.6.8.1, the find command will immediately abort and report
>>   some stale nfs handles.
> 
> 
> Do you mean it will report ESTALE when the server goes down, or when
> it comes back up?

Immediately when the server goes down. "find" and "cp" immediately
abort and I'm back on the shell prompt.

cu,
Frank

-- 
Dipl.-Inform. Frank Steiner   Web:  http://www.bio.ifi.lmu.de/~steiner/
Lehrstuhl f. Bioinformatik    Mail: http://www.bio.ifi.lmu.de/~steiner/m/
LMU, Amalienstr. 17           Phone: +49 89 2180-4049
80333 Muenchen, Germany       Fax:   +49 89 2180-99-4049
* Rekursion kann man erst verstehen, wenn man Rekursion verstanden hat. *


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
