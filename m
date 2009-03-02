From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: redundant reverse DNS on NFS mount or umount
Date: Mon, 2 Mar 2009 12:44:17 -0500
Message-ID: <AE947E73-264F-433C-B428-C8E9F4374A4F@oracle.com>
References: <499AD63B.20806@draigBrady.com> <20090302174155.GF967@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed	delsp=yes
Cc: =?ISO-8859-1?Q?P=E1draig_Brady?= <P@draigBrady.com>,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:35052 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753166AbZCBRoi convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Mar 2009 12:44:38 -0500
In-Reply-To: <20090302174155.GF967@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mar 2, 2009, at Mar 2, 2009, 12:41 PM, J. Bruce Fields wrote:
> On Tue, Feb 17, 2009 at 03:22:35PM +0000, P=E1draig Brady wrote:
>> I've a problem where reverse DNS is being done by the NFS server.
>> This is very problematic when the DNS server goes away.
>> As far as I can see there should be no lookups being performed
>> because I've nothing in /etc/hosts.{allow,deny} and just
>> numeric hosts in /etc/exports.
>>
>> I can simulate this easily by putting a bad nameserver in /etc/=20
>> resolv.conf
>> and restarting the nfs server. Any mounts will take then take ages.
>> Others seem to have had this issue as well, but possibly with
>> non numeric names in /etc/exports:
>> http://marc.info/?l=3Dlinux-nfs&m=3D110977757630297&w=3D2
>> http://marc.info/?l=3Dlinux-nfs&m=3D111015343008456&w=3D2
>>
>> Here are my config details:
>>
>> # rpm -q nfs-utils
>> nfs-utils-1.1.0-6.fc8
>>
>> # cat /etc/resolv.conf
>> search company.com
>> nameserver 192.168.2.110
>>
>> # cat /etc/exports
>> /home   192.168.2.25(async,rw,all_squash,anonuid=3D500,anongid=3D500=
)
>>
>> Any ideas appreciated.
>
> I agree that DNS lookups shouldn't be required in this case.
>
> It's rpc.mountd that's responsible for this, so if you can figure out
> where in the mountd code this is happening, it shouldn't be hard to =20
> fix.

That would most likely be matchhostname().

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com