Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cdptpa-omtalb.mail.rr.com ([75.180.132.122]:48245 "EHLO
	cdptpa-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751150Ab1G3Evc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 30 Jul 2011 00:51:32 -0400
Received: from [192.168.0.251] (PBENDER1.bendercasa.net [192.168.0.251])
	(authenticated bits=0)
	by server.bendercasa.net (8.13.8/8.13.8) with ESMTP id p6U4pTmn031710
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES128-SHA bits=128 verify=NO)
	for <linux-nfs@vger.kernel.org>; Fri, 29 Jul 2011 21:51:29 -0700
Message-ID: <4E338DD1.9070704@san.rr.com>
Date: Fri, 29 Jul 2011 21:51:29 -0700
From: Paul Bender <pebender@san.rr.com>
Reply-To: pebender@san.rr.com
To: linux-nfs@vger.kernel.org
Subject: problem with the --enable-libmount-mount configure option
Content-Type: multipart/mixed;
 boundary="------------010900030901020706020207"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--------------010900030901020706020207
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

nfs-utils' configure script assumes that when either
--enable-libmount-mount
or
--disable-libmount-mount
is specified, that libmount should be used. The attached patch fixes the 
problem for me.

--------------010900030901020706020207
Content-Type: application/gzip;
 name="nfs-utils-1.2.4-enable_libmount.patch.gz"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="nfs-utils-1.2.4-enable_libmount.patch.gz"

H4sICD8FM04AA25mcy11dGlscy0xLjIuNC1lbmFibGVfbGlibW91bnQucGF0Y2gAhY5Ba4NAEIXP
7q+YQw+KznZ3YyIVCtqypAEjweZQCEFMou1Su0LUhv77itZD6iFzmIE337w3J1UUgHHWnkEXNbaN
KmvkVFAXq/J0f6x0od7bc06z4wTQ+eUKIIh408UQjHNkC5wxYAufMd8VlI0FyDzGiG3bN9P+jDwU
D8C5Pxe+O58YBQEgn3mOB/YwgoCAET6nYbJMZRw+RdIs1eGranWDfXe6vbHriBcZbdLXbbKKl+YO
MdfZoczxGt73dMdHSn9CL9Hub7io5gNGFEz5tpHJai3jbRhZe6u7QsMYDNORevzJa4fYU/1uEL6z
sg/7v9aVRaBQBMgv0i0ZmMsBAAA=

--------------010900030901020706020207--
