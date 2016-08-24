Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:31949 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932428AbcHXSnW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 24 Aug 2016 14:43:22 -0400
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: Christoph Hellwig <hch@lst.de>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        "trondmy.myklebust@primarydata.com"
        <trondmy.myklebust@primarydata.com>,
        "Schumaker, Anna" <Anna.Schumaker@netapp.com>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@rhel7-2-ga-3.androsad.fake>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH Version-2 03/12] VFS permit cross device
        vfs_copy_file_range
Date: Wed, 24 Aug 2016 18:38:10 +0000
Message-ID: <A5646713-CB18-4492-831F-0D2D3BC5BAE9@netapp.com>
References: <1471627512-4102-1-git-send-email-andros@netapp.com>
 <1471627512-4102-4-git-send-email-andros@netapp.com>
 <20160819210844.GR32329@fieldses.org> <20160820061833.GA6812@lst.de>
In-Reply-To: <20160820061833.GA6812@lst.de>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

DQo+IE9uIEF1ZyAyMCwgMjAxNiwgYXQgMjoxOCBBTSwgQ2hyaXN0b3BoIEhlbGx3aWcgPGhjaEBs
c3QuZGU+IHdyb3RlOg0KPiANCj4gT24gRnJpLCBBdWcgMTksIDIwMTYgYXQgMDU6MDg6NDRQTSAt
MDQwMCwgSi4gQnJ1Y2UgRmllbGRzIHdyb3RlOg0KPj4gSSB0aG91Z2h0IEkgcmVtZW1iZXJlZCBD
aHJpc3RvcGggKGNjJ2QpIGFyZ3VpbmcgYXQgdGhlIDIwMTUgbHNmL21tIHRoYXQNCj4+IHRoZXJl
IHdlcmUgc29tZSBtb3JlIGlzc3VlcyB0aGF0IHdvdWxkIG5lZWQgdG8gYmUgdGFrZW4gY2FyZSBv
ZiBiZWZvcmUNCj4+IHdlIGNvdWxkIHR1cm4gb24gY3Jvc3MtZGV2aWNlIGNvcGllcy4NCj4gDQo+
IFllcy4gIE5vaSBvdGhlciBWRlMgb3BlcmF0aW9uIGlzIHN1cHBvcnRlZCBiZXR3ZWVuIG1vdW50
cG9pbnQsIHNvDQo+IGNvcHlfZmlsZV9yYW5nZSBzaG91bGRuJ3QgYmUgZWl0aGVyLg0KDQpIaSBD
aHJpc3RvcGgNCg0KQXMgeW91IGtub3cgKGJlY2F1c2UgeW91IHJldmlld2VkIHRoZSBwYXRjaCks
IHRoZSBvcmlnaW5hbCBpbnRlbnQgb2YgdnNfY29weV9maWxlX3JhbmdlIGFzIHN0YXRlZCBpbiB0
aGUgc3lzY2FsbCBzdWJtaXNzaW9uIGZyb20gWmFjaCBCcm93biAoY29tbWl0OiA4ODRhMTJhNTk3
MmZjODY3YTkzZjdhZGY3YThhYzJhZGU1ZDM4ZmZmICkgaXMgdG8gYWxsb3cgY29waWVzIGJldHdl
ZW4gZmlsZSBzeXN0ZW1zIOKAnG9uY2Ugd2UgZ2V0IGltcGxlbWVudGF0aW9ucyB3aGljaCBjb3B5
IGJldHdlZW4gdGlsZSBzeXN0ZW1zIHNhZmVseeKAnQ0KDQpORlN2NCBpbnRlciBzZXJ2ZXIgdG8g
c2VydmVyIGNvcHkgd2lsbCBwcm92aWRlIGFuIGltcGxlbWVudGF0aW9uIHdoaWNoIGNhbiBjb3B5
IGJldHdlZW4gdGlsZSBzeXN0ZW1zIHNhZmVseSAtIHNvIEkgZG9u4oCZdCB1bmRlcnN0YW5kIHlv
dXIgb2JqZWN0aW9uIHRvIHRoaXMgZXZlbnR1YWwgdXNlIG9mIHZmc19jb3B5X2ZpbGVfcmFuZ2Uu
DQoNCj4gDQo+IEFsc28gYSBnZW5lcmFsIE5BSyB0byBhbnkgbmV3IGNvcHlfZmlsZV9yYW5nZSB3
b3JrIGJlZm9yZSB3ZSBoYXZlDQo+IHByb3BlciB4ZnN0ZXN0cyBjb3ZlcmFnZS4gIEFuZCBpdCdz
IG5vdCBsaWtlIHRoZSBjb3ZlcmFnZSBpcyBoYXJkLA0KPiB3ZSBhbHJlYWR5IGhhdmUgMTAwcyBv
ZiB0ZXN0cyBmb3IgY2xvbmUsIHdoaWNoIGluIG1hbnkgd2F5IGlzIHZlcnkNCj4gc2ltaWxhciBh
bmQgY291bGQgYmUgcGFydGlhbGx5IHJldXNlZC4NCg0KWWVzIC0gYWdyZWVkLiBBbm5hIGlzIHdv
cmtpbmcgb24gdXBkYXRlZCB4ZnN0ZXN0cyBmb3IgTkZTdjQgaW50cmEgc2VydmVyIHRvIHNlcnZl
ciBjb3B5IGFzIHdlbGwgYXMgZXhwYW5kaW5nIHRoZSB4ZnN0ZXN0cyBmb3Igb3RoZXIgdmZzX2Nv
cHlfZmlsZV9yYW5nZSBmZWF0dXJlcy4gV2UgY2FuIGxvb2sgYXQgZXhwYW5kaW5nIHRoZSB0ZXN0
cyBmb3IgdGhlIGludGVyIHNlcnZlciB0byBzZXJ2ZXIgY2FzZS4gIEpvcmdlIE1vcmEgYXV0aG9y
IG9mIE5GU1Rlc3RzIGlzIGFsc28gd29ya2luZyBvbiBhIHRlc3Qgc3VpdGUgZm9yIGludGVyIHNl
cnZlciB0byBzZXJ2ZXIgY29weS4gDQoNCg==
