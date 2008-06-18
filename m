From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 2/4] NFS: Support raw IPv6 address hostnames during NFS
 mount	operation
Date: Wed, 18 Jun 2008 18:42:33 -0400
Message-ID: <48598F59.2040505@oracle.com>
References: <20080618222951.16006.3679.stgit@ellison.1015granger.net> <20080618223203.16006.61765.stgit@ellison.1015granger.net> <48598DB7.4060404@redhat.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050005060801000905000508"
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
To: Peter Staubach <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:42052 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754186AbYFRWnP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Jun 2008 18:43:15 -0400
In-Reply-To: <48598DB7.4060404@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050005060801000905000508
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Peter Staubach wrote:
> Chuck Lever wrote:
>> Traditionally the mount command has looked for a ":" to separate the
>> server's hostname from the export path in the mounted on device name,
>> like this:
>>
>>     mount server:/export /mounted/on/dir
>>
>> The server's hostname is "server" and the export path is "/export".
>>
>> You can also substitute a specific IPv4 network address for the server
>> hostname, like this:
>>
>>     mount 192.168.0.55:/export /mounted/on/dir
>>
>> Raw IPv6 addresses present a problem, however, because they look
>> something like this:
>>
>>     fe80::200:5aff:fe00:30b
>>
>> Note the use of colons.
>>
>> To get around the presence of colons, copy the Solaris convention used 
>> for
>> mounting IPv6 servers by address: wrap a raw IPv6 address with square
>> brackets.
>>
>>   
> 
> It seems unfortunate that the convention couldn't have been to
> look for the first instance of ":/" and break the strings there.

I wonder if you can ever specify an export path that does not begin with 
a '/' -- is that possible when mounting an NFS server that exports, say, 
an old-fashioned HFS volume?

   "macintosh::Macintosh HD:Users:cel"

Looking for only the first colon gives the correct results in this case, 
but looking for ":/" would not.

Likewise on FAT32:

   "windows:\Documents and Settings\Chuck Lever\My Documents"

--------------050005060801000905000508
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck_lever.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="chuck_lever.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Chuck
org:Oracle Corporation;Corporate Architecture: Linux Projects Group
adr:;;1015 Granger Avenue;Ann Arbor;MI;48104;USA
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
version:2.1
end:vcard


--------------050005060801000905000508--
