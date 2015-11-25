Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail3.dit.upm.es ([138.4.2.18]:35105 "EHLO mail3.dit.upm.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752049AbbKYQYA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Nov 2015 11:24:00 -0500
MIME-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8;
 format=flowed
Date: Wed, 25 Nov 2015 16:23:55 +0000
From: omar <omar@dit.upm.es>
To: <bfields@fieldses.org>
Cc: <linux-nfs@vger.kernel.org>,
        =?UTF-8?Q?=27Administraci=C3=B3n_del_Cen?=
	 =?UTF-8?Q?tro_de_C=C3=A1lculo_del_DIT=27?= <cdc@dit.upm.es>
Subject: Re: possible bug in nfs-kernel-server
In-Reply-To: <20151123211815.GA13935@fieldses.org>
References: <564EFE51.90105@dit.upm.es>
 <20151123211815.GA13935@fieldses.org>
Message-ID: <dd656612ed089cf922aa6cbf1f7a742d@dit.upm.es>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Hi, thanks for the answer. I'm out of the office until next week, but 
when I come back, I'll try to do the tests and send you the info.

Thank you very much,

Omar

El 2015-11-23 21:18, bfields@fieldses.org escribió:
> On Fri, Nov 20, 2015 at 12:04:49PM +0100, Omar Walid Llorente wrote:
>>
>> Hi, I'm Omar Walid Llorente and I am a systems administrator at the
>> Politechnical University of Madrid (UPM), Spain. I write you in the
>> hope you can help us manage a problem that have discovered recently
>> about our new datastore architecture in our teaching labs. We have
>> created a gluster distributed volume that we reexport with NFS to
>> our lab clients via intermediate servers.
>>
>> First of all thanks for all your work and sorry if this isn't
>> related with your package, but I think it has a good chance. I'll
>> try explain myself as short as possible.
>>
>> As introduced previously, we have a problem exporting with
>> nfs-kernel-server-1.2.8-6 (ubuntu based) a directory previously
>> mounted with gluster-3.7.4 via fuse mount.
>>
>> The problem is quite simple to reproduce and always repeatable: if a
>> file has read-only permissions for owner and user wants to copy it,
>> permissions problem arises:
>> cdc@client:~$ rm -f kk.txt 444.txt; echo "prueba" > 444.txt; chmod
>> 444 444.txt; cp -p 444.txt kk.txt; ls -ld 444.txt kk.txt
>> cp: failed to close ‘kk.txt’: Permission denied
>> -r--r--r-- 1 cdc admincdc 7 nov  3  2015 444.txt
>> -r--r--r-- 1 cdc admincdc 0 nov  3  2015 kk.txt
>> cdc@client:~$
>>
>> If the file permissions are not read-only, there is no problem:
>> cdc@client:~$ rm -f kk.txt 644.txt; echo "prueba" > 644.txt; chmod
>> 644 644.txt; cp -p 644.txt kk.txt; ls -ld 644.txt kk.txt
>> -rw-r--r-- 1 cdc admincdc 7 nov  3  2015 644.txt
>> -rw-r--r-- 1 cdc admincdc 7 nov  3  2015 kk.txt
>> cdc@client:~$
>>
>> If we track it down with strace, the problem arises exactly when
>> fsync() is called from cp.
>
> So, cp is calling fsync on kk.txt before closing it?
>
>> Of course, if we try this combination of commands in other
>> directories not mounted by nfs (local ones) or mounted with
>> samba/cifs or even mounted with nfs-ganesha (both fuse mounted with
>> gluster), this doen't happen. This problem doesn't happen either if
>> the nfs-kernel-server exports a directory not mounted with fuse (any
>> local one).
>>
>> Please, tell me if this is the right place to post the probem and
>> where is it if this is not. Let me know if we can help you any way
>> to solve or test it (we've developed a small program in c that shows
>> exactly the same behaviour).
>
> It'd be interesting to see exactly which NFS operation is failing.  
> You
> should be able to do this by running wireshark to sniff the NFS
> client/server traffic while running the reproducer, then reading 
> through
> the traffic to find the failing operation.
>
> I'm also curious:
>
>> LOGS ON SERVER SIDE (glusterfs mount logs):
>> [2015-11-20 10:51:53.872656] I [io-stats.c:1014:io_stats_dump_fd]
>> 0-home-lab-3: --- fd stats ---
>> [2015-11-20 10:51:53.872692] I [io-stats.c:1019:io_stats_dump_fd]
>> 0-home-lab-3:       Filename : /cdc/444.txt
>> [2015-11-20 10:51:53.872704] I [io-stats.c:1034:io_stats_dump_fd]
>> 0-home-lab-3:   BytesWritten : 7 bytes
>> [2015-11-20 10:51:53.872714] I [io-stats.c:1046:io_stats_dump_fd]
>> 0-home-lab-3: Write 000004b+ : 1
>> [2015-11-20 10:51:53.874917] W [MSGID: 114031]
>> [client-rpc-fops.c:1298:client3_3_removexattr_cbk]
>> 0-home-lab-3-client-0: remote operation failed [Permission denied]
>> [2015-11-20 10:51:53.874976] W [fuse-bridge.c:1230:fuse_err_cbk]
>> 0-glusterfs-fuse: 63459954: REMOVEXATTR() /cdc/444.txt => -1
>> (Permission denied)
>> [2015-11-20 10:51:53.881389] W [MSGID: 114031]
>> [client-rpc-fops.c:1298:client3_3_removexattr_cbk]
>> 0-home-lab-3-client-3: remote operation failed [Permission denied]
>> [2015-11-20 10:51:53.881434] W [fuse-bridge.c:1230:fuse_err_cbk]
>> 0-glusterfs-fuse: 63459961: REMOVEXATTR() /cdc/kk.txt => -1
>> (Permission denied)
>
> I wonder what this is about?  Why would an fsync on the NFS client
> result in a REMOVEXATTR on the server side?
>
> --b.
>
>> [2015-11-20 10:51:53.883072] W [fuse-bridge.c:1230:fuse_err_cbk]
>> 0-glusterfs-fuse: 63459964: REMOVEXATTR() /cdc/kk.txt => -1
>> (Permission denied)
>> [2015-11-20 10:51:53.883057] W [MSGID: 114031]
>> [client-rpc-fops.c:1298:client3_3_removexattr_cbk]
>> 0-home-lab-3-client-3: remote operation failed [Permission denied]
>> [2015-11-20 10:51:53.884003] E [MSGID: 114031]
>> [client-rpc-fops.c:466:client3_3_open_cbk] 0-home-lab-3-client-3:
>> remote operation failed. Path: /cdc/kk.txt
>> (3175e0cd-8308-45b8-a4b0-699f6f8cf37f) [Permission denied]
>> [2015-11-20 10:51:53.884056] W [fuse-bridge.c:969:fuse_fd_cbk]
>> 0-glusterfs-fuse: 63459965: OPEN() /cdc/kk.txt => -1 (Permission
>> denied)
>> [2015-11-20 10:51:53.885619] W [MSGID: 114031]
>> [client-rpc-fops.c:1298:client3_3_removexattr_cbk]
>> 0-home-lab-3-client-3: remote operation failed [Permission denied]
>> [2015-11-20 10:51:53.885664] W [fuse-bridge.c:1230:fuse_err_cbk]
>> 0-glusterfs-fuse: 63459967: REMOVEXATTR() /cdc/kk.txt => -1
>> (Permission denied)
>> [2015-11-20 10:51:53.887908] W [fuse-bridge.c:1230:fuse_err_cbk]
>> 0-glusterfs-fuse: 63459971: REMOVEXATTR() /cdc/kk.txt => -1
>> (Permission denied)
>> [2015-11-20 10:51:53.887891] W [MSGID: 114031]
>> [client-rpc-fops.c:1298:client3_3_removexattr_cbk]
>> 0-home-lab-3-client-3: remote operation failed [Permission denied]
>>
>> (NOTE: We have more gluster brick logs but we don't know if are 
>> relevant)
>>
>> --
>> ----------------------------------------------------------------
>> Centro de Cálculo         Depto. Ingeniería Sistemas Telemáticos
>> E-mail: omar@dit.upm.es        Universidad Politécnica de Madrid
>> Fax:(+34) 913367333                 E.T.S. Ing. Telecomunicación
>> Tel:(+34) 915495700-Ext.3005                28040 Madrid (Spain)
>> Tel:(+34) 915495762-Ext.3005
>> Tel:(+34) 913367366-Ext.3005
>> ----------------------------------------------------------------
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" 
>> in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

