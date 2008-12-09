From: Le Rouzic <aime.le-rouzic@bull.net>
Subject: Re: NFSD IPv6 support for 2.6.29
Date: Tue, 09 Dec 2008 13:37:20 +0100
Message-ID: <493E6680.2050904@bull.net>
References: <9BBD5BD5-C461-43C4-AEB0-69D3E31F92B7@oracle.com> <4917C380.9040703@linux.vnet.ibm.com> <C44F9C62-2770-4879-8AC7-B1C8D81F9AB6@oracle.com> <491AFE09.2010803@bull.net> <2BF8FCDB-0C6D-430E-B2AE-4C293E30A1AE@oracle.com> <4921AF45.4070009@bull.net> <AF604C91-2F1B-48A3-8E1D-84D5CBBB2856@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Cc: Varun Chandramohan <varunc@linux.vnet.ibm.com>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	Frank S Filz <ffilz@us.ibm.com>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:41284 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751416AbYLIMh1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Dec 2008 07:37:27 -0500
In-Reply-To: <AF604C91-2F1B-48A3-8E1D-84D5CBBB2856@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever a =E9crit :

>>>>>>> Bruce asked me to collect server-side IPv6 patches for upstream=
=2E
>>>>>>> I've collected the patches that have been posted on the list, a=
nd
>>>>>>> added some fixes of my own.
>>>>>>>
>>>>>>> Can you have a look at
>>>>>>>
>>>>>>> http://git.linux-nfs.org/?p=3Dcel/cel-2.6.git;a=3Dsummary
>>>>>>>
>>>>>>> tag cel-ipv6-10292008
>>>>>>>
>>>>>>> These have been build tested, but I haven't done any run-time
>>>>>>> testing yet.
>>>>>>>
>>>>>>> --=20
>>>>>>> Chuck Lever
>>>>>>> chuck[dot]lever[at]oracle[dot]com
>>>>>>
>> Hi
>> I have tested the "tag cel-ipv6-10292008" and some robustness tests
>> started simultaneously (connectathon, fsx, iozone, fss_stress, ffsb)=
 =20
>> have
>> been running fine during several hours in IPV6 and IPV4.
>> I used the my nfs-utils package based on nfs-utils.1.1.2
>> (http://nfsv4.bullopensource.org/)
>
    Hi,
    I get an issue with AIX used as client in front of the above=20
snapshot used on a linux server.
   =20
     Doing the following on the AIX side:
   =20
       mount -o vers=3D4 nfs4gb:/ /mnt/nosec
       cd /mnt/nosec
       mkdir rep
       cd rep

       the command "ls" will fail with the follwing error on the AIX si=
de:
     "kern:err|error unix: Client encounters unexpected=20
NFS4ERR_BAD_COOKIE error from server"

      The problem happens with IPV6 and IPV4
     =20
      Best Regards

--=20
-----------------------------------------------------------------
Company : Bull, Architect of an Open World TM (www.bull.com)
Name    : Aime Le Rouzic=20
Mail    : Bull - BP 208 - 38432 Echirolles Cedex - France
E-Mail  : aime.le-rouzic@bull.net
Phone   : 33 (4) 76.29.75.51
=46ax     : 33 (4) 76.29.75.18
-----------------------------------------------------------------=20

