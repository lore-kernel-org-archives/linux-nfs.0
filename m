From: "xurui" <xur@nanjing-fnst.com>
Subject: Re: Some uncomformity between the realization of the kernel
	and the RFC1813
Date: Wed, 1 Nov 2006 11:40:25 +0800
Message-ID: <009301c6fd67$77a68b60$8904a8c0@xurui>
References: <008001c6fd5f$2c350330$8904a8c0@xurui>
	<20061101025052.GA32052@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gf6yu-0008WB-MW
	for nfs@lists.sourceforge.net; Tue, 31 Oct 2006 19:41:36 -0800
Received: from [221.6.14.228] (helo=proxy.fnst.com.cn)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gf6yu-0002zd-Pn
	for nfs@lists.sourceforge.net; Tue, 31 Oct 2006 19:41:37 -0800
To: "J. Bruce Fields" <bfields@fieldses.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

> Why do you assume that?
Our assumption is according to the RFC1813(Page 34) described as follows:
"If the server receives a full file COMMIT request, that is starting at 
offset 0 and count 0, it should do the equivalent of fsync()'ing the file. 
Otherwise, it should arrange to have the cached data in the range specified 
by offset and count to be flushed to stable storage."

It shows that when we set the offset and count, the server should cached the 
data among this arrange, not the full data in the cache. We don't know why 
kernel design it like this .

>That doesn't sound like the right behavior to me.  What if the file has
> been truncated on the server without the client's knowledge?  Isn't it
> better in that case to flush out whatever range remains instead of
> failing the commit?


We assume that when server receives these packages, it may return fail 
message. or others, My question is that if we set the legal offset and count 
and their sum is smaller than the file size , the server still flush all 
data to the stable storage, not the data specified by the count and offset. 
So we believe that some unconformity between the realization of the kernel 
and the RFC1813.


Thank you for your reply.

----- Original Message ----- 
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "xurui" <xur@nanjing-fnst.com>
Cc: <nfs@lists.sourceforge.net>
Sent: Wednesday, November 01, 2006 10:50 AM
Subject: Re: [NFS] Some uncomformity between the realization of the 
RHEL5Beta1 and the RFC1813


> On Wed, Nov 01, 2006 at 10:41:03AM +0800, xurui wrote:
>>  struct COMMIT3args { nfs_fh3    file; offset3    offset; count3
>>  count; };
> ...
>>
>>
>> When we send the package with the sum of the augment count and offset
>> larger than the file size ,which will lead to the overflow ,we assumed
>> that nfs server will return fail message,
>
> Why do you assume that?
>
> That doesn't sound like the right behavior to me.  What if the file has
> been truncated on the server without the client's knowledge?  Isn't it
> better in that case to flush out whatever range remains instead of
> failing the commit?
>
> --b. 


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
