Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-oa0-f45.google.com ([209.85.219.45]:38680 "EHLO
	mail-oa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754060AbaEPHbY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 May 2014 03:31:24 -0400
Received: by mail-oa0-f45.google.com with SMTP id l6so2563251oag.4
        for <linux-nfs@vger.kernel.org>; Fri, 16 May 2014 00:31:23 -0700 (PDT)
Message-ID: <5375BEBD.50805@gmail.com>
Date: Fri, 16 May 2014 15:31:09 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2] NFSD: Don't clear SUID/SGID after root writing data
References: <534AA92B.8010805@gmail.com> <20140418130220.GF18612@fieldses.org> <53512DE5.7050907@gmail.com> <5351501B.1010507@gmail.com> <20140508161256.GC20976@fieldses.org> <536C89D7.6090902@gmail.com> <20140509214056.GC497@fieldses.org> <20140510051017.GA23444@infradead.org>
In-Reply-To: <20140510051017.GA23444@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On 5/10/2014 13:10, Christoph Hellwig wrote:
> On Fri, May 09, 2014 at 05:40:57PM -0400, J. Bruce Fields wrote:
>> On Fri, May 09, 2014 at 03:55:03PM +0800, Kinglong Mee wrote:
>>> On 5/9/2014 00:12, J. Bruce Fields wrote:
>>>> I'd like to apply this if only to remove the redundant code.
>>>>
>>>> I'd like to understand, though, whether this is something that caused an
>>>> actual practical problem for someone, or if you just happened to notice
>>>> the inconsistency between nfs and ext4 behavior?
>>>
>>> I test it with ext2,ext3,btrfs,xfs.
>>> Test result is same as ext4.
>>> So, we needs remove the redundant killing of suid/sgid.
>>
>> Understood that this would make the behavior consistent with
>> filesystems.  But, you don't know of any cases of the current behavior
>> is actually causing a problem for anyone? 
> 
> I thin this also is the root cause for xfstests generic/193 failing on
> NFS, but I haven't verified it yet.

xfstests generic/193 only tests non-root user truncating file
with root setting SGID/SUID mode. generic/193 will not fail.

236 _create_files
237 # Now test out the clear of suid/sgid for truncate
238 #
239 echo "check that suid/sgid bits are cleared after successful truncate..."
240
241 echo "with no exec perm"
242 echo frobnozzle >> $test_user
243 chmod ug+s $test_user
244 echo -n "before: "; stat -c '%A' $test_user
245 su ${qa_user} -c "echo > $test_user"
246 echo -n "after:  "; stat -c '%A' $test_user
247
248 echo "with user exec perm"
249 echo frobnozzle >> $test_user
250 chmod ug+s $test_user
251 chmod u+x $test_user
252 echo -n "before: "; stat -c '%A' $test_user
253 su ${qa_user} -c "echo > $test_user"
254 echo -n "after:  "; stat -c '%A' $test_user
255
256 echo "with group exec perm"
257 echo frobnozzle >> $test_user
258 chmod ug+s $test_user
259 chmod g+x $test_user
260 chmod u-x $test_user
261 echo -n "before: "; stat -c '%A' $test_user
262 su ${qa_user} -c "echo > $test_user"
263 echo -n "after:  "; stat -c '%A' $test_user
264
265 echo "with user+group exec perm"
266 echo frobnozzle >> $test_user
267 chmod ug+s $test_user
268 chmod ug+x $test_user
269 echo -n "before: "; stat -c '%A' $test_user
270 su ${qa_user} -c "echo > $test_user"
271 echo -n "after:  "; stat -c '%A' $test_user

thanks,
Kinglong Mee
