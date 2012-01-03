Return-Path: linux-nfs-owner@vger.kernel.org
Received: from email2.etri.re.kr ([129.254.16.132]:35039 "EHLO
	email2.etri.info" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750743Ab2ACFdY convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Jan 2012 00:33:24 -0500
MIME-Version: 1.0
Content-Type: text/plain;
	charset="ks_c_5601-1987"
Subject: Question about direct IO in pnfs 
Date: Tue, 3 Jan 2012 14:33:22 +0900
Message-ID: <5E11524165CB9F4889E16DC6D29BAAD5021AD1BF@email2>
From: =?ks_c_5601-1987?B?sei89r+1?= <sykim@etri.re.kr>
To: <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These days, I¡¯m studying pnfs¡¯ functionalities.

It seems that the pnfs code does not support direct I/O.

Actually, in direct IO mode, the generic_file_aio_read() is not called. 

Is there a plan to support direct IO in pnfs?

And in nfs_file_direct_read() comment,

what¡¯s meaning of the sentence(in order to avoid gfar¡¯s check ~ end of file)?

/**   
 * nfs_file_direct_read - file direct read operation for NFS files     
 * @iocb: target I/O control block 
 * @iov: vector of user buffers into which to read data 
 * @nr_segs: size of iov vector  
 * @pos: byte offset in file where reading starts 
 *   
 * We use this function for direct reads instead of calling 
 * generic_file_aio_read() in order to avoid gfar's check to see if     
 * the request starts before the end of the file. For that check     
 * to work, we must generate a GETATTR before each direct read, and     
 * even then there is a window between the GETATTR and the subsequent     
 * READ where the file size could change. Our preference is simply     
 * to do all reads the application wants, and the server will take     
 * care of managing the end of file boundary. 
 *   
 * This function also eliminates unnecessarily updating the file's     
 * atime locally, as the NFS server sets the file's atime, and this     
 * client must read the updated atime from the server back into its     
 * cache.   
 */

---------------------------------------------------------------------
SOO-YOUNG KIM
Senior Member of Engineering Staff
Storage System Research Team
Electronics and Telecommunications Research Institute

138 Gajeong-no, Yuseong-gu, Daejeon, 305-700 KOREA
Phone : 82-42-860-1682 Fax : 82-42-860-6699 
Mobile : 82-10-9696-3032 E-mail : sykim@etri.re.kr
ETRI Homepage : www.etri.re.kr
---------------------------------------------------------------------

