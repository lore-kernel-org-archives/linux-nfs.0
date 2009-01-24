From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [RFC] [PATCH v2 0/1] nfsd: Improve NFS server performance
Date: Sat, 24 Jan 2009 18:04:57 +0530
Message-ID: <20090124123457.10995.57636.sendpatchset@localhost.localdomain>
Cc: linux-nfs@vger.kernel.org, Krishna Kumar <krkumar2@in.ibm.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:45321 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751641AbZAXMfE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 24 Jan 2009 07:35:04 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e8.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n0OCSnst022592
	for <linux-nfs@vger.kernel.org>; Sat, 24 Jan 2009 07:28:49 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n0OCZ3nk177514
	for <linux-nfs@vger.kernel.org>; Sat, 24 Jan 2009 07:35:03 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n0OCY7S3005051
	for <linux-nfs@vger.kernel.org>; Sat, 24 Jan 2009 07:34:07 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>

			Patch summary:
			--------------

Change the caching from ino/dev to a file handle model. Advantages:

1. Since file handles are unique, this patch removes all dependencies on the
   kernel readahead parameters and it's implementation; and instead caches
   files based on file handles.

2. Allows the server to not have to open/close a file multiple times when the
   client reads it, and results in faster lookup times.

3. Readahead is automatically taken care of since the file is not closed while
   it is getting read (quickly) by the client.

4. Another optimization is to avoid getting the cache lock twice for each read
   operation (after the first time it is taken to update the cache).


			List of changes from Ver1:
			--------------------------

1. Implement entire logic of either updating-cache or do-nothing or close-file
   in fh_cache_upd. This simplifies the caller (nfsd_read).

2. nfsd_get_fhcache doesn't overwrite existing entries which would require the
   existing entries to be freed up - that is done by the daemon exclusively.
   This saves time at lookup by avoiding freeing entries (fh_cache_put).
   Another change is to optimize the logic of selecting a free slot.

3. Due to #2, fh_cache_upd doesn't have to test whether the entry is already
   on the daemon list (it never is, plus list_del_init is changed to list_del).

4. As a result of #2, the daemon becomes simpler - there is no race to handle
   where there is an entry on the list but it has no cached file/dentry, etc.

5. Made some comments clearer and easier to understand.


			Performance:
			-------------

This patch was tested with clients running 2, 4, 8, 16 --- 256 test processes,
each doing reads of different files. Each test includes different I/O sizes.
31/77 tests got more than 5% improvement; with 5 tests getting more than 10%
gain (full results at the end of this post).

Please review. Any comments or improvement ideas are appreciated.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---

		(#Test Processes on Client == #NFSD's on Server)
-----------------------------------------------------------------------
#Test Processes Bufsize		Org BW KB/s	New BW KB/s	%
-----------------------------------------------------------------------
2		256		68022.46	71094.64	4.51
2		4096		67833.74	70726.38	4.26
2		8192		64541.14	69635.93	7.89
2		16384		65708.86	68994.88	5.00
2		32768		64272.28	68525.36	6.61
2		65536		64684.13	69103.28	6.83
2		131072		64765.67	68855.57	6.31

4		256		60849.48	64702.04	6.33
4		4096		60660.67	64309.37	6.01
4		8192		60506.00	61142.84	1.05
4		16384		60796.86	64069.82	5.38
4		32768		60947.07	64648.57	6.07
4		65536		60774.45	63735.24	4.87
4		131072		61369.66	65261.85	6.34

8		256		49239.57	54467.33	10.61
8		4096		50650.45	55400.01	9.37
8		8192		50661.58	51732.16	2.11
8		16384		51114.76	56025.31	9.60
8		32768		52367.20	54348.05	3.78
8		65536		51000.23	54285.63	6.44
8		131072		52996.73	54021.11	1.93

16		256		44534.67	45478.60	2.11
16		4096		43897.69	46519.89	5.97
16		8192		43787.87	44083.61	.67
16		16384		43883.62	46726.03	6.47
16		32768		44284.96	44035.86	-.56
16		65536		43804.33	44865.20	2.42
16		131072		44525.30	43752.62	-1.73

32		256		40420.30	42575.30	5.33
32		4096		39913.14	42279.21	5.92
32		8192		40261.19	42399.93	5.31
32		16384		38094.95	42645.32	11.94
32		32768		40610.27	43015.37	5.92
32		65536		41438.05	41794.76	.86
32		131072		41869.06	43644.07	4.23

48		256		36986.45	40185.34	8.64
48		4096		36585.79	38227.38	4.48
48		8192		38406.78	38055.91	-.91
48		16384		34950.05	36688.86	4.97
48		32768		38908.71	37900.33	-2.59
48		65536		39364.64	40036.67	1.70
48		131072		40391.56	40887.11	1.22

64		256		32821.89	34568.06	5.32
64		4096		35468.42	35529.29	.17
64		8192		34135.44	36462.31	6.81
64		16384		31926.51	32694.91	2.40
64		32768		35527.69	35234.60	-.82
64		65536		36066.08	36359.77	.81
64		131072		35969.04	37462.86	4.15

96		256		30032.74	29973.45	-.19
96		4096		29687.06	30881.64	4.02
96		8192		31142.51	32504.66	4.37
96		16384		29546.77	30663.39	3.77
96		32768		32458.94	32797.36	1.04
96		65536		32826.99	33451.66	1.90
96		131072		33601.46	34177.39	1.71

128		256		28584.59	29092.11	1.77
128		4096		29311.11	30097.65	2.68
128		8192		31398.87	33154.63	5.59
128		16384		28283.58	29071.45	2.78
128		32768		32819.93	33654.11	2.54
128		65536		32617.13	33778.46	3.56
128		131072		32972.71	34160.82	3.60

192		256		25245.92	26331.48	4.29
192		4096		27368.48	29318.49	7.12
192		8192		30173.74	31477.35	4.32
192		16384		26388.54	29719.15	12.62
192		32768		31840.91	33606.17	5.54
192		65536		33374.85	33607.14	.69
192		131072		33523.48	32601.93	-2.74

256		256		22256.91	21139.79	-5.01
256		4096		25192.75	24281.51	-3.61
256		8192		26534.95	28100.59	5.90
256		16384		24162.85	25607.86	5.98
256		32768		29218.38	29417.28	.68
256		65536		29609.59	30049.79	1.48
256		131072		30014.29	30132.33	.39
-----------------------------------------------------------------------
