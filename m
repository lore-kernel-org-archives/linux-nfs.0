Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:50038 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754370Ab3HESSG convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Aug 2013 14:18:06 -0400
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 6.5 \(1508\))
Subject: Re: [RFC 4/5] NFSD: Defer copying
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20130805181121.GA1583@fieldses.org>
Date: Mon, 5 Aug 2013 14:17:50 -0400
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Ric Wheeler <rwheeler@redhat.com>,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <8591C722-A99A-4E4A-86E5-B9F207B8AB95@oracle.com>
References: <20130722185002.GB10109@fieldses.org> <51ED8549.3040308@netapp.com> <20130722193000.GD10109@fieldses.org> <51ED89DC.7050406@netapp.com> <20130722194331.GF10109@fieldses.org> <51ED8DD8.1060703@netapp.com> <20130722195556.GG10109@fieldses.org> <51FF647C.3020704@redhat.com> <20130805144127.GA31169@fieldses.org> <1375714236.7337.5.camel@leira.trondhjem.org> <20130805181121.GA1583@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Aug 5, 2013, at 2:11 PM, "J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Mon, Aug 05, 2013 at 02:50:38PM +0000, Myklebust, Trond wrote:
>> On Mon, 2013-08-05 at 10:41 -0400, J. Bruce Fields wrote:
>>> Bryan suggested in offline discussion that one possibility might be to
>>> copy, say, at most a gigabyte at a time before returning and making the
>>> client continue the copy.
>>> 
>>> Where for "a gigabyte" read, "some amount that doesn't take too long to
>>> copy but is still enough to allow close to full bandwidth".  Hopefully
>>> that's an easy number to find.
>>> 
>>> But based on
>>> http://tools.ietf.org/html/draft-ietf-nfsv4-minorversion2-19#section-14.1.2
>>> the COPY operation isn't designed for that--it doesn't give the option
>>> of returning bytes_copied in the successful case.
>> 
>> The reason is that the spec writers did not want to force the server to
>> copy the data in sequential order (or any other particular order for
>> that matter).
> 
> Well, servers would still have the option not to return success unless
> the whole copy succeeded, so I'm not sure this *forces* servers to do
> sequential copies.
> 
> (Unless we also got rid of the callback.)

If the client initiates a full-file copy and the operation fails, I would think that the client itself can try copying sufficiently large chunks of the file via separate individual COPY operations.  If any of those operations fails, then the client can fall back again to a traditional over-the-wire copy operation.


> --b.
> 
>> 
>> If the copy was short, then the client can't know which bytes were
>> copied; they could be at the beginning of the file, in the middle, or
>> even the very end. Basically, it needs to redo the entire copy in order
>> to be certain.
>> 
>>> Maybe we should fix that in the spec, or maybe we just need to implement
>>> the asynchronous case.  I guess it depends on which is easier,
>>> 
>>> 	a) implementing the asynchronous case (and the referring-triple
>>> 	   support to fix the COPY/callback races), or
>>> 	b) implementing this sort of "short copy" loop in a way that gives
>>> 	   good performance.
>>> 
>>> On the client side it's clearly a) since you're forced to handle that
>>> case anyway.  (Unless we argue that *all* copies should work that way,
>>> and that the spec should ditch the asynchronous case.) On the server
>>> side, b) looks easier.
>>> 
>>> --b.
>> 
>> -- 
>> Trond Myklebust
>> Linux NFS client maintainer
>> 
>> NetApp
>> Trond.Myklebust@netapp.com
>> www.netapp.com
>> N?????r??y????b?X??ǧv?^?)޺{.n?+????{???"??^n?r???z???h?????&???G???h?(?階?ݢj"???m??????z?ޖ???f???h???~?m
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




