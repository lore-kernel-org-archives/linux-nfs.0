From: Steve Dickson <SteveD@redhat.com>
Subject: Re: mount: RPC: Timed out
Date: Fri, 15 Aug 2003 09:40:44 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F3CE2DC.9080102@RedHat.com>
References: <000501c36325$43ffe750$8c35a8c0@peter>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pix-525-pool.redhat.com ([66.187.233.200] helo=lacrosse.corp.redhat.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19neoO-0005u0-00
	for <nfs@lists.sourceforge.net>; Fri, 15 Aug 2003 06:40:12 -0700
To: Peter Albertsson <Peter.Albertsson@naturesown.se>
In-Reply-To: <000501c36325$43ffe750$8c35a8c0@peter>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Would it be possible to get an ethereal trace?

Peter Albertsson wrote:

>I believe so, this is what I get:=20
>
>[root@frankenstein root]# rpcinfo -p
>   program vers proto   port
>    100000    2   tcp    111  portmapper
>    100000    2   udp    111  portmapper
>    100024    1   udp  32768  status
>    100024    1   tcp  32768  status
>    391002    2   tcp  32769  sgi_fam
>    100011    1   udp    931  rquotad
>    100011    2   udp    931  rquotad
>    100011    1   tcp    934  rquotad
>    100011    2   tcp    934  rquotad
>    100003    2   udp   2049  nfs
>    100003    3   udp   2049  nfs
>    100021    1   udp  32770  nlockmgr
>    100021    3   udp  32770  nlockmgr
>    100021    4   udp  32770  nlockmgr
>    100005    1   udp  32771  mountd
>    100005    1   tcp  32770  mountd
>    100005    2   udp  32771  mountd
>    100005    2   tcp  32770  mountd
>    100005    3   udp  32771  mountd
>    100005    3   tcp  32770  mountd
>
>I've gone through the troubleshooter for nfs at redhat.com, but that
>didn't solve the problem. Everything seems to be configured right,
>but....
>
>I've read somewhere that it could be that a ns lookup is made, and that
>this may cause the time out. Neither the client or server is registered
>with any dns, but have its domain names set in the hosts file. Could
>this be a problem?
>
>// Peter
>
>
>
>-----Ursprungligt meddelande-----
>Fr=E5n: Steve Dickson [mailto:SteveD@RedHat.com]=20
>Skickat: den 15 augusti 2003 13:06
>Till: Peter Albertsson
>Kopia: nfs@lists.sourceforge.net
>=C4mne: Re: [NFS] mount: RPC: Timed out
>
>Is mountd running on the server?
>
>SteveD.
>
>Peter Albertsson wrote:
>
> =20
>
>>Could someone please help me with the following problem.
>>
>>This is what happens when I try to mount a nfs share on a client.
>>
>>
>>[root@frankenstein3 etc]# mount -t nfs 192.168.53.200:/var/www /var/www
>>mount: RPC: Timed out
>>[root@frankenstein3 etc]#
>>
>>If I mount the share on the same server it works fine.
>>
>>
>>Netstat on client:
>>
>>[root@frankenstein3 root]# netstat -n
>>Active Internet connections (w/o servers)
>>Proto Recv-Q Send-Q Local Address           Foreign Address
>>State
>>tcp        0      0 192.168.53.136:895      192.168.53.200:111
>>TIME_WAIT
>>
>>On server no connections show up at all.
>>
>>I've seen this problem being discussed on this mailing list and some
>>other places, but I haven't found a solution.
>>
>>The server is running on Red Hat 9.0.
>>
>>Thanks,
>> // Peter
>>
>>
>>
>>
>>-------------------------------------------------------
>>This SF.Net email sponsored by: Free pre-built ASP.NET sites including
>>Data Reports, E-commerce, Portals, and Forums are available now.
>>Download today and enter to win an XBOX or Visual Studio .NET.
>>http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_0
>>   =20
>>
>1/01
> =20
>
>>_______________________________________________
>>NFS maillist  -  NFS@lists.sourceforge.net
>>https://lists.sourceforge.net/lists/listinfo/nfs
>>=20
>>
>>   =20
>>
>
>
>
> =20
>



-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
