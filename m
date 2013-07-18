Return-Path: linux-nfs-owner@vger.kernel.org
Received: from science.horizon.com ([71.41.210.146]:39101 "HELO
	science.horizon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S934054Ab3GRVb2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Jul 2013 17:31:28 -0400
Date: 18 Jul 2013 17:31:26 -0400
Message-ID: <20130718213126.12710.qmail@science.horizon.com>
From: "George Spelvin" <linux@horizon.com>
To: dhowells@redhat.com, joe@perches.com, linux@horizon.com
Subject: Re: [PATCH] Assoc_array: Drop leaf-type concept
Cc: keyrings@linux-nfs.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-security-module@vger.kernel.org
In-Reply-To: <21160.1374153504@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Looks cleaner.

The larger issues that bother me:

1) The fact that the abstract daya type "index key" provides access to
   a byte string "index key" is a bit confusing.  I'd describe it as
   follows:  (Based on my current understanding.)


   Each object has an associated "index key" that is used for lookup.
   The index key is a string of bits which is stored "inside" the object,
   however all access to it is done through method functions, so it is
   not necessary to explicitly store it anywhere.

   For example, it is possible to have the leading portion of the
   index_key be a hash of the remainder.

   Index keys may be variable-length, but must be self-delimiting.
   Specifically, two different index keys must differ at some bit position
   before the end of the shorter of the two.

   Some index key methods take an isolated "const void *index_key"
   argument, while others take an object pointer.

2) The code does not look 32-bit safe.  In particular, keyring_get_key_chunk
   assumes the hash is BITS_PER_LONG long, but keyring_diff_objects 
   assumes it's 8*8 bits...

3) I presume you looked at wider tries like Judy arrays and found that
   a fan-out of 16 was better?

4) There are 3/7 unused bytes in an assoc_array_node, after parent_slot.
   Would it be worth storing 16/48 bits of index key and 3/4 bits of
   number of levels to skip per assoc_array_node?
   Since parent_slot is actually only 4 bits, you could store 4 bits
   of nubmer of levels and 56 bits (up to 14 levels, plus the one
   from the famout) of index key.

   With 32-way fanout, you could fit 5 bits of parent index, 25/55 bits of
   index key, and encode the number of levels to skip (0-5/11) more carefully.

5) The big question: Why not use a hash table?  That's what people
   usually expect when you say "associative array".  It would be simpler
   and faster.

   RCU-safe resizeable hash tables are tricky, but a solved problem,
   There are universal hashing techniques for preventing hash collision
   attacks.  
