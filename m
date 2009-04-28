From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: nfs-utils-1.1.6 released.
Date: Tue, 28 Apr 2009 11:23:49 -0400
Message-ID: <5406185E-847B-4416-BBDD-7190D630B8ED@oracle.com>
References: <49ECB9E6.4010001@RedHat.com> <49EDFE21.2000007@arx.net> <49EF3A83.50409@RedHat.com> <20090422155427.GA8712@fieldses.org> <49F6E9B3.2090508@arx.net>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=UTF-8;
	format=flowed	delsp=yes
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Steve Dickson <SteveD@redhat.com>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Thanos Chatziathanassiou <tchatzi-nz9JlX+3IF8@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:43306 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762730AbZD1PYd convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Apr 2009 11:24:33 -0400
In-Reply-To: <49F6E9B3.2090508-nz9JlX+3IF8@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 28, 2009, at 7:34 AM, Thanos Chatziathanassiou wrote:
> O/H J. Bruce Fields =CE=AD=CE=B3=CF=81=CE=B1=CF=88=CE=B5:
>> On Wed, Apr 22, 2009 at 11:40:51AM -0400, Steve Dickson wrote:
>>
>>> Thanos Chatziathanassiou wrote:
>>>
>>>> Installed nfs-utils-1.1.6 and I'm facing an issue:
>>>>
>>>> on the server:
>>>> # cat /etc/exports
>>>> /opt/shared/home
>>>> 192.168.99.0/255.255.255.0(rw,no_root_squash,no_subtree_check,sync=
)
>>>>
>>>> # cat /var/lib/nfs/etab
>>>> /opt/shared/home   =20
>>>> 192.168.99.0=20
>>>> /=20
>>>> 255.255.255.0=20
>>>> (rw=20
>>>> ,sync=20
>>>> ,wdelay=20
>>>> ,hide=20
>>>> ,nocrossmnt=20
>>>> ,secure=20
>>>> ,no_root_squash=20
>>>> ,no_all_squash=20
>>>> ,no_subtree_check,secure_locks,acl,anonuid=3D65534,anongid=3D65534=
)
>>>>
>>>>
>>>> on the client:
>>>> # cat /proc/mounts
>>>> nfsip:/opt/shared/home /home nfs
>>>> rw=20
>>>> ,noatime=20
>>>> ,vers=20
>>>> =3D=20
>>>> 3=20
>>>> ,rsize=20
>>>> =3D8192,wsize=3D8192,hard,intr,proto=3Dudp,timeo=3D11,retrans=3D2,=
addr=3Dnfsip
>>>> 0 0
>>>>
>>>> however, everyone (including root) gets mapped to uid 65534 despit=
e
>>>> no_root_squash and no_all_squash...not very useful for a home =20
>>>> directory.
>>>> Is there something I'm missing ?
>>>>
>>> Wow... That is very strange...
>>
>> Might be worth looking at the network traffic to see if some change =
=20
>> in
>> the client or in the mountd security negotiation hasn't caused the
>> client to start doing auth_null instead of auth_unix?
>>
>> --b.
>>
> Apologies for taking so long, but I was out of the office last week.
> I'm attaching a tcpdump of mounting the directory ``/vhome'' and =20
> doing a ``touch lala'' (my very own ``foo'') in said directory, =20
> which resulted in access denied on the client.
> It doesn't say much to me, but then again I'm certainly no expert.
>>
>>> any type of failures in /var/log/messages?
>>>
> Nothing obvious, at least. Just:
> Apr 28 14:06:30 nfs mountd[1115]: authenticated mount request from =20
> 192.168.99.6:637 for /opt/shared/vhome (/opt/shared/vhome)
> on the server. nothing on the client.
>
> By the way, umounting the directory on the client results in this =20
> being printed out to stderr:
> ``umount.nfs: address family not supported by DNS resolver''
> which I saw in utils/mount/network.c.

That's a bug in nfsumount.c.  I'll post a patch for it.

> It was missing a ``%s'' in the attached patch, which resulted in
> ``umount.nfs: address family not supported by DNS resolver =20
> (192.168.99.20)''
> when added.

>>> Also tried to go back to the previous (1.1.1) nfs-utils, but after
>>>> ``exportfs -ra'' the the server spit a few of those and all =20
>>>> mounts froze
>>>> nfs mountd[1115]: /var/lib/nfs/etab:1: unknown keyword =20
>>>> "mapping=3Didentity"
>>>>
>>> I don't see a 'mapping' entry in the above 'cat /var/lib/nfs/etab'?
> me neither (?)
>>> steved.
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-=20
>>> nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
> Let me know if I can be of any assistance.
>
> <nfs.pkt>--- network.c.orig	Mon Apr 20 20:32:50 2009
> +++ network.c	Tue Apr 21 20:21:23 2009
> @@ -266,7 +266,7 @@
> 	*salen =3D 0;
>
> 	if (af_hint !=3D AF_INET) {
> -		nfs_error(_("%s: address family not supported by DNS resolver\n"),
> +		nfs_error(_("%s: address family not supported by DNS resolver (%s)=
=20
> \n"),
> 				progname, hostname);

If you are hitting this function, then your glibc doesn't have =20
AI_ADDRCONFIG?  Can you tell us what distribution this is?  (And =20
perhaps which version of glibc is installed?)

(This is probably not related to your other problem, but it is =20
unexpected with a late-model 2.6.x kernel).

> 		return 0;
> 	}

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com