From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: NFS mount over IPv6 success
Date: Wed, 12 Nov 2008 11:28:25 -0500
Message-ID: <6C1A5772-DC24-4777-B41E-694B65D73408@oracle.com>
References: <20081109164132.GA19615@uio.no> <DBEFEF5C-00E2-4C4D-A9D4-81D24632DE34@oracle.com> <20081112133553.GA32294@uio.no> <491AFEB9.1090208@bull.net>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed	delsp=yes
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Le Rouzic <aime.le-rouzic@bull.net>,
	"Steinar H. Gunderson" <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:55602 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750714AbYKLQ3K convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Nov 2008 11:29:10 -0500
In-Reply-To: <491AFEB9.1090208@bull.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 12, 2008, at 11:05 AM, Le Rouzic wrote:

> Steinar H. Gunderson a =E9crit :
>
>> On Wed, Nov 12, 2008 at 01:00:27AM -0500, Chuck Lever wrote:
>>
>>
>>> Keep an eye out for IPv6-related patches for nfs-utils.  The key =20
>>> is to
>>> ensure IPv4 continues to work, especially on Debian which tracks
>>> upstream nfs-utils closely.
>>>
>>>
>>
>> We don't plan to incorporate IPv6-specific patches before upstream =20
>> does (and
>> lenny, our upcoming release, is not going to get libtirpc or =20
>> rpcbind). When
>> upstream nfs-utils is ready, you can expect us to configure with
>> --enable-ipv6 pretty quickly, though :-)
>>
>> I still haven't had any success with nfsd on the server side in =20
>> Linux; it's a
>> bit unclear to me what nfs-utils to use in particular.
>>
>> /* Steinar */
>>
>>
> Hi,
> There is a prototype nfs-utils package based on nfs-utils-1.1.2 you =20
> can
> play with at http://nfsv4.bullopensource.org/

Oops.  Sorry, I forgot about that.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com