From: Steve Dickson <steved@4Dicksons.org>
Subject: Re: How does lockd work when specifying mountd port.
Date: Tue, 21 Jan 2003 17:23:43 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3E2DC86F.2070508@4Dicksons.org>
References: <871y3fwmh8.fsf@prium.net> <3E2CB6DF.8050409@4Dicksons.org> <87k7gyzi6i.fsf@prium.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from nat-pool-rdu.redhat.com ([66.187.233.200] helo=lacrosse.corp.redhat.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18b6n4-0008Nt-00
	for <nfs@lists.sourceforge.net>; Tue, 21 Jan 2003 14:22:42 -0800
To: Erik Enge <eenge@prium.net>, nfs@lists.sourceforge.net
In-Reply-To: <87k7gyzi6i.fsf@prium.net>
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

it turns out with RH8.0 (maybe earlier versions as well) you can
specify the port at insmod time by setting nlm_udpport or
nlm_tcpport

You can also sett nlm_grace_period and nlm_timeout as well...

Erik Enge wrote:

>Steve Dickson <SteveD@4Dicksons.org> writes:
>
>  
>
>>Lockd gets an enumerated port number and then registers
>>it with the portmapper. Then processes ask portmapper
>>(or rpcbind if your talking to Solaris) for the port. so you will
>>have to open up the port after lockd has started.  IMHO, This may not
>>be too wise to opening up all these ports,
>>you might want to think of using a VPN or SSH....
>>    
>>
>
>Thanks for your reply.
>
>Is there no way I can specify this port and have all processes use the
>same port and then open only that one through the firewall?
>
>I guess this means that I'm not using lockd at the moment.  Not
>devastating considering we have virtually only one NFS client.
>
>Erik.
>  
>



-------------------------------------------------------
This SF.net email is sponsored by: Scholarships for Techies!
Can't afford IT training? All 2003 ictp students receive scholarships.
Get hands-on training in Microsoft, Cisco, Sun, Linux/UNIX, and more.
www.ictp.com/training/sourceforge.asp
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
