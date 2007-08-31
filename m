From: Bernd Schubert <bernd-schubert@gmx.de>
Subject: slowness due to splitting into pages in
	nfs3svc_decode_writeargs()
Date: Fri, 31 Aug 2007 20:03:30 +0200
Message-ID: <200708312003.30446.bernd-schubert@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IRAqG-0008AZ-LH
	for nfs@lists.sourceforge.net; Fri, 31 Aug 2007 11:03:37 -0700
Received: from mail.gmx.net ([213.165.64.20])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1IRAqI-0001bt-T9
	for nfs@lists.sourceforge.net; Fri, 31 Aug 2007 11:03:39 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi,

I'm presently investigating why writing to a nfs exported lustre filesystem is 
rather slow. Reading from lustre over nfs about 200-300 MB/s, but writing to 
it over nfs is only 20-50MB/s (both with IPoIB). Writing directly to this 
lustre cluster is about 600-700 MB/s both reading and writing. Well, 200-300 
MB/s over NFS per client would be acceptable.

After several dozens of printks, systemtaps, etc I think its not the fault of 
lustre, but a generic nfsd and/or vfs problem.
In nfs3svc_decode_writeargs() all the data received are splitted into 
PAGE_SIZE, except the very first page. This page only gets 
PAGE_SIZE - header_length. So far no problem, but now on writing the pages in 
generic_file_buffered_write(), this function tries to write PAGE_SIZE. So it 
takes the first nfs page, which is PAGE_SIZE - header_length. 
To fill up to PAGE_SIZE it will take header_length from the second page. Of 
course, now there's also only PAGE_SIZE - header_length for the 2nd nfs page 
left. 
It will continue this way until the last page is written. Don't know why this 
doesn't show a big effect on other file system. Well, maybe it does, but 
nobody did notice it before?

Well, I have no idea if generic_file_buffered_write() really has to do what it 
presently does. But lets first stay at nfs, is it really necessary to already 
split up the data into pages? 

Using this patch I get write speed of about 200 MB/s, even with kernel 
debugging enabled and several left-over printks 

-- nfs3xdr.c.bak	2007-07-09 01:32:17.000000000 +0200
+++ nfs3xdr.c	2007-08-31 19:29:31.000000000 +0200
@@ -405,16 +405,8 @@ nfs3svc_decode_writeargs(struct svc_rqst
 		len = args->len = max_blocksize;
 	}
 	rqstp->rq_vec[0].iov_base = (void*)p;
-	rqstp->rq_vec[0].iov_len = rqstp->rq_arg.head[0].iov_len - hdr;
-	v = 0;
-	while (len > rqstp->rq_vec[v].iov_len) {
-		len -= rqstp->rq_vec[v].iov_len;
-		v++;
-		rqstp->rq_vec[v].iov_base = page_address(rqstp->rq_pages[v]);
-		rqstp->rq_vec[v].iov_len = PAGE_SIZE;
-	}
-	rqstp->rq_vec[v].iov_len = len;
-	args->vlen = v + 1;
+	rqstp->rq_vec[0].iov_len = len;
+	args->vlen = 1;
 	return 1;
 }


Cheers,
Bernd 

-- 
Bernd Schubert
Q-Leap Networks GmbH

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
