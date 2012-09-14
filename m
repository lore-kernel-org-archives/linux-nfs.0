Return-Path: linux-nfs-owner@vger.kernel.org
Received: from avasout04.plus.net ([212.159.14.19]:51806 "EHLO
	avasout04.plus.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759284Ab2INIfj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Sep 2012 04:35:39 -0400
Message-ID: <5052EAEB.7060309@plus.net>
Date: Fri, 14 Sep 2012 09:29:31 +0100
From: Richard Allen <rallen@plus.net>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Debian and Netapp NFSv4 locks/owner exhaustion
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,

We're currently having a highly intermittent (and seemingly random) 
problem with our 20 Debian clients running courier POP3 and IMAPd 
connecting to a Netapp filer using NFSv4, whereby locks/owner objects 
are being maxed out on the filer, causing the clients to start to have 
very high load.

Netapp think that this is a bug with the implementation of NFS in our 
Debian kernel - please see part of an email they sent us below:

---
"Thanks for providing all the  data
from the sync core and the lock status data provided indicated you have 
a linux client bug. equivalent to redhat bugzilla > 620502/621304 .

https://bugzilla.redhat.com/show_bug.cgi?id=620502  2.6.18 kernel
https://bugzilla.redhat.com/show_bug.cgi?id=621304  2.6.32 kernel.

Basically there is a know linux kernel bug where it request a new owner 
id everytime a new lock request is submitted. There are linux upstream 
fixed that prevents new owner lock id and reuse existing ones.

Analyses from the sync core

As previously mentioned NFSv4 has 4 items StateID/ClientID and OwnerID 
limits.

StateID
kgdb-amd64-7.4-54) p v4lock_states_free_count
$8 = {16789, 32768}
 >>>>>>There are free states available.

ClientID
(kgdb-amd64-7.4-54) p v4lock_clients_free[0]
$10 = {{cqh_first = 0xffffff04cd2cda00, cqh_last = 0xffffff04cd4caf00}
 >>> there are free clients

OwnerID
(kgdb-amd64-7.4-54) p v4lock_owners_free[0]
$9 = {{cqh_first = 0xffffffffa25f2640, cqh_last = 0xffffffffa25f2640}
 >>>there are no free owners

(kgdb-amd64-7.4-54) print_owner_htab_count
total:10240
 >>>>total owner objects in use:10240

(kgdb-amd64-7.4-54) p v4owner_table_size/2
$527 = 10240
 >>>>per node max owners value reached


Lets correlate this to the lock status output provided.

(fed15:samuell:/x/eng/cs-data/2003058003/20120821_sync_core/mailstorage04> 
grep "Free owners" mailstorage04-lock-v*
mailstorage04-lock-v-201208210605:Free owners 3; In-Use Owners 10237 *
mailstorage04-lock-v-201208210610:Free owners -3; In-Use Owners 10243 *
mailstorage04-lock-v-201208210615:Free owners -2; In-Use Owners 10242
mailstorage04-lock-v-201208210620:Free owners 0; In-Use Owners 10240
mailstorage04-lock-v-201208210625:Free owners 3; In-Use Owners 10237
mailstorage04-lock-v-201208210630:Free owners -7; In-Use Owners 10247
mailstorage04-lock-v-201208210635:Free owners 1; In-Use Owners 10239
mailstorage04-lock-v-201208210640:Free owners -3; In-Use Owners 10243
mailstorage04-lock-v-201208210645:Free owners 4; In-Use Owners 10236
mailstorage04-lock-v-201208210650:Free owners -1; In-Use Owners 10241
mailstorage04-lock-v-201208210655:Free owners 4; In-Use Owners 10236
mailstorage04-lock-v-201208210700:Free owners -1; In-Use Owners 10241
mailstorage04-lock-v-201208210705:Free owners -4; In-Use Owners 10244

As you can see the filer is reporting MAX of 10240 and in some event it 
was over subscribed.

Corrective action is to make sure you use a kernel release from your 
distro that has upstream patch

The diff can be found here
https://bugzilla.redhat.com/attachment.cgi?id=436801&action=diff


Redhat has provided an errata fix int he kernel patch

http://rhn.redhat.com/errata/RHSA-2011-0542.html"
---

Some info on our platform:

Clients:
20 of, running Squeeze 6.0.1, but with backported kernel 
3.2.0-0.bpo.1-amd64.
nfs-common 1:1.2.2-4
The application is courier IMAP and POP3.

Server:
Netapp FAS3170 running 8.0.1P1 7-Mode

The main question I have is whether the bugs Netapp mentioned in the 
Redhat kernel have been fixed in the backported Debian kernel we are 
running, and if so, what version the fixes have been introduced in (and 
if not, what version the fixes *will* be introduced in)?

Otherwise, if anyone has any other suggestions as to what else the 
problem could be, I'd be happy to hear them

Thanks,

Richard

