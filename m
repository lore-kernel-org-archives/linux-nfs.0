Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f174.google.com ([209.85.217.174]:61525 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751677Ab2FDKbT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Jun 2012 06:31:19 -0400
Received: by lbbgm6 with SMTP id gm6so2950747lbb.19
        for <linux-nfs@vger.kernel.org>; Mon, 04 Jun 2012 03:31:18 -0700 (PDT)
Message-ID: <4FCC8E6D.9020106@openvz.org>
Date: Mon, 04 Jun 2012 14:31:09 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
To: Hans de Bruin <jmdebruin@xmsnet.nl>
CC: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: nfsroot client will not start firefox or thunderbird from 3.4.0
 nfsserver
References: <4FC3F9F6.7010107@xmsnet.nl> <4FC913FC.2020401@xmsnet.nl> <4FCB7C11.7070300@xmsnet.nl>
In-Reply-To: <4FCB7C11.7070300@xmsnet.nl>
Content-Type: multipart/mixed;
 boundary="------------090302080802030505020007"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090302080802030505020007
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hans de Bruin wrote:
> On 06/01/2012 09:11 PM, Hans de Bruin wrote:
>> On 05/29/2012 12:19 AM, Hans de Bruin wrote:
>>> I just upgraded my home server from kernel 3.3.5 to 3.4.0 and ran into
>>> some trouble. My laptop, a nfsroot client, will not run firefox and
>>> thunderbird anymore. When I start these programs from an xterm, the
>>> cursor goes to the next line and waits indefinitely.
>>>
>>> I do not know if there is any order is lsof's output. A lsof | grep
>>> firefox or thunderbird shows ......./.parentlock as the last line.
>>>
>>> It does not matter whether the client is running a 3.4.0 or a 3.3.0
>>> kernel, or if the server is running on top of xen or not.
>>>
>>> There is some noise in the servers dmesg:
>>>
>>> [ 241.256684] INFO: task kworker/u:2:801 blocked for more than 120
>>> seconds.
>>> [ 241.256691] "echo 0>  /proc/sys/kernel/hung_task_timeout_secs"
>>
>> ...
>>
>> On a almost identical testsystem firefox en thunderbird segfault after
>> upgrading to 3.4.0. I would have been nice if it would behave exaclty
>> like my home server. I bisected the segfault to:
>>
>> commit 0fc9d1040313047edf6a39fd4d7c7defdca97c62
>> Author: Konstantin Khlebnikov<khlebnikov@openvz.org>
>> Date: Wed Mar 28 14:42:54 2012 -0700
>>
>> radix-tree: use iterators in find_get_pages* functions
>>
>>
>> When I revert that on top of 3.4.0 the segfaults are gone but both
>> firefox en thunderbird go in the lets wait indefinitely mode like the
>> homeserver.
>>
>> I am going to make a bit-wise copy from from my homeserver to my
>> testserver and try again.
>>
>
> The bit-wise copy also segfaults firefox and thunderbird at the same
> commit.
>

I think bug somewhere in NFS, that patch only highlighted it.
Please, try to run it with debug patch from attachment.

--------------090302080802030505020007
Content-Type: text/plain;
 name="mm-debug-fing_get_pages-speculative-restart"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="mm-debug-fing_get_pages-speculative-restart"

mm: debug fing_get_pages speculative restart

From: Konstantin Khlebnikov <khlebnikov@openvz.org>

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 mm/filemap.c |    9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/mm/filemap.c b/mm/filemap.c
index a4a5260..a8cffef 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -815,6 +815,7 @@ unsigned find_get_pages(struct address_space *mapping, pgoff_t start,
 	struct radix_tree_iter iter;
 	void **slot;
 	unsigned ret = 0;
+	int nr_found = 0;
 
 	if (unlikely(!nr_pages))
 		return 0;
@@ -846,6 +847,7 @@ repeat:
 			continue;
 		}
 
+		nr_found++;
 		if (!page_cache_get_speculative(page))
 			goto repeat;
 
@@ -861,6 +863,7 @@ repeat:
 	}
 
 	rcu_read_unlock();
+	WARN_ON(!ret && nr_found);
 	return ret;
 }
 
@@ -882,6 +885,7 @@ unsigned find_get_pages_contig(struct address_space *mapping, pgoff_t index,
 	struct radix_tree_iter iter;
 	void **slot;
 	unsigned int ret = 0;
+	int nr_found = 0;
 
 	if (unlikely(!nr_pages))
 		return 0;
@@ -913,6 +917,7 @@ repeat:
 			break;
 		}
 
+		nr_found++;
 		if (!page_cache_get_speculative(page))
 			goto repeat;
 
@@ -937,6 +942,7 @@ repeat:
 			break;
 	}
 	rcu_read_unlock();
+	WARN_ON(!ret && nr_found);
 	return ret;
 }
 EXPORT_SYMBOL(find_get_pages_contig);
@@ -958,6 +964,7 @@ unsigned find_get_pages_tag(struct address_space *mapping, pgoff_t *index,
 	struct radix_tree_iter iter;
 	void **slot;
 	unsigned ret = 0;
+	int nr_found = 0;
 
 	if (unlikely(!nr_pages))
 		return 0;
@@ -988,6 +995,7 @@ repeat:
 			BUG();
 		}
 
+		nr_found++;
 		if (!page_cache_get_speculative(page))
 			goto repeat;
 
@@ -1007,6 +1015,7 @@ repeat:
 	if (ret)
 		*index = pages[ret - 1]->index + 1;
 
+	WARN_ON(!ret && nr_found);
 	return ret;
 }
 EXPORT_SYMBOL(find_get_pages_tag);

--------------090302080802030505020007--
