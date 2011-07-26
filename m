Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:53763 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753570Ab1GZT3M (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Jul 2011 15:29:12 -0400
Received: by vxh35 with SMTP id 35so571688vxh.19
        for <linux-nfs@vger.kernel.org>; Tue, 26 Jul 2011 12:29:12 -0700 (PDT)
Message-ID: <4E2F1584.60901@marcanoonline.com>
Date: Tue, 26 Jul 2011 14:59:08 -0430
From: Robert Marcano <robert@marcanoonline.com>
To: linux-nfs@vger.kernel.org
Subject: Re: NFSv4 / POSIX ACL mapping bug?
References: <4E2ED2A0.4030401@marcanoonline.com> <D7BF98E9-394A-4364-8124-1E39BEBE85DC@netapp.com>
In-Reply-To: <D7BF98E9-394A-4364-8124-1E39BEBE85DC@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 07/26/2011 02:03 PM, Andy Adamson wrote:
> Hi
>
> Which client, which server (distro and uname -a output) did you use? Also, what commands (setfacl,getfacl? nfs4_setfacl, nfs4_getfacl ? plus version) and parameters did you use?

Thanks, here is the missing data

NFS Server:
   CentOS release 5.6
   Linux *** 2.6.18-238.9.1.el5 #1 SMP Tue Apr 12 18:10:13 EDT 2011 
x86_64 x86_64 x86_64 GNU/Linux

Client:
   Fedora 15
   Linux *** 2.6.38.7-30.fc15.i686.PAE #1 SMP Fri May 27 05:44:56 UTC 
2011 i686 i686 i386 GNU/Linux

The acls are POSIX ACLs assigned server side

=================================================
Commands on the CentOS NFS server:
not on the NFS mounted directory but on the source filesystem that is 
exported, using root
=================================================
# umask 022
# mkdir directory
# setfacl -m d:g:sharedgroup:rwx directory
# setfacl -m g:sharedgroup:rwx directory
# touch directory/server
# getfacl directory/server

# file: directory/server
# owner: root
# group: root
user::rw-
group::r-x			#effective:r--
group:sharedgroup:rwx		#effective:rw-
mask::rw-
other::r--


=================================================
Commands on the Fedora NFS client:
using a non root user (a Kerberos authenticated user in our setup named 
test)
=================================================
$ umask 022
$ touch directory/client

=================================================
Commands on the CentOS NFS server:
=================================================
# getfacl directory/client

# file: directory/client
# owner: test
# group: ipausers
user::rw-
group::r-x			#effective:r--
group:sharedgroup:rwx		#effective:r--
mask::r--
other::r--

When the file is created locally it gets the default ACL from 
"directory" with mask "mask::rw-"

Thanks in advance


>
> -->Andy
> On Jul 26, 2011, at 10:43 AM, Robert Marcano wrote:
>
>> Hi, This question is probably too simple for this nfs developer list, but I am intrigued to know if this is a bug or not, I do not find any other reference to anyone with this problem
>>
>> Ineed some help clarifying this issue in order to know if this is a bug or limits of the NFSv4 / POSIX ACL mapping before reporting it
>>
>> Creating a directory on the server with the following POSIX ACLs, rwx for the group "sharedgroup" and same defaults:
>>
>> ############################################################
>> # file: directory
>> # owner: root
>> # group: root
>> user::rwx
>> group::r-x
>> group:sharedgroup:rwx
>> mask::rwx
>> other::---
>> default:user::rwx
>> default:group::r-x
>> default:group:sharedgroup:rwx
>> default:mask::rwx
>> default:other::---
>> ############################################################
>>
>> Creating files with the same user with umask 022 on the server an on the NFS client, the files do not get the same POSIX ACL mask:
>>
>> ############################################################
>> # file: client
>> # owner: test
>> # group: testgroup
>> user::rw-
>> group::r-x                   #effective:r--
>> group:sharedgroup:rwx        #effective:r--
>> mask::r--
>> other::r--
>>
>> # file: server
>> # owner: test
>> # group: testgroup
>> user::rw-
>> group::r-x                   #effective:r--
>> group:sharedgroup:rwx        #effective:rw-
>> mask::rw-
>> other::r--
>> ############################################################
>>
>> Is this normal or a bug?, My interpretation is that even that the mapping of the ACLs is not 100% perfect this simple example should not be a problem. Is it impossible using NFS to create a shared directory for a group of users?
>>
>> Thanks in advance
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

