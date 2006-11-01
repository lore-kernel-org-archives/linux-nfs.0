From: Peter Staubach <staubach@redhat.com>
Subject: Re: Some uncomformity between the realization of the kernel
 and the RFC1813
Date: Wed, 01 Nov 2006 09:21:35 -0500
Message-ID: <4548AD6F.7020109@redhat.com>
References: <008001c6fd5f$2c350330$8904a8c0@xurui>	<20061101025052.GA32052@fieldses.org>
	<009301c6fd67$77a68b60$8904a8c0@xurui>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GfGyQ-0006Tk-OK
	for nfs@lists.sourceforge.net; Wed, 01 Nov 2006 06:21:46 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GfGyN-0000ez-KJ
	for nfs@lists.sourceforge.net; Wed, 01 Nov 2006 06:21:48 -0800
To: xurui <xur@nanjing-fnst.com>
In-Reply-To: <009301c6fd67$77a68b60$8904a8c0@xurui>
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

xurui wrote:
>> Why do you assume that?
>>     
> Our assumption is according to the RFC1813(Page 34) described as follows:
> "If the server receives a full file COMMIT request, that is starting at 
> offset 0 and count 0, it should do the equivalent of fsync()'ing the file. 
> Otherwise, it should arrange to have the cached data in the range specified 
> by offset and count to be flushed to stable storage."
>
> It shows that when we set the offset and count, the server should cached the 
> data among this arrange, not the full data in the cache. We don't know why 
> kernel design it like this .
>
>   
>> That doesn't sound like the right behavior to me.  What if the file has
>> been truncated on the server without the client's knowledge?  Isn't it
>> better in that case to flush out whatever range remains instead of
>> failing the commit?
>>     
>
>
> We assume that when server receives these packages, it may return fail 
> message. or others, My question is that if we set the legal offset and count 
> and their sum is smaller than the file size , the server still flush all 
> data to the stable storage, not the data specified by the count and offset. 
> So we believe that some unconformity between the realization of the kernel 
> and the RFC1813.

Please be aware that in this respect, RFC1813 describes the minimal that
a server must do.  If the server implementation decides to write more cached
data to stable storage than it was requested to do, then it is free to 
do so.
All of the cached data at the server must be written to stable storage at
some time or another and writing it sooner as opposed to later is better
for stability purposes.

The intent is that the server do at least what was requested, not less.  
More
can be good if it does not significantly impact performance and can 
potentially
lead to better performance and/or a simpler implementation.  A simpler
implementation can often lead to a more stable implementation.

    Thanx...

       ps

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
